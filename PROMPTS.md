# PROMPTS

Chronological record of the prompts used to build the Comment Create Mutation and List Tweets
Query features, what came back, and whether the result was accepted.

Prompt wording is taken from `prompt_notes.txt`. Entries 1 and 2 cover the tooling setup that
preceded those notes. Lettered items (A, B, …) are questions Claude asked back mid-prompt, with
the answer given.

---

## 1. Set up the feature-development skill

> set up feature-development

**What came back:** Read the project for existing rules, CI config and branch conventions, found
none documented, and asked for the three choices it could not infer. Wrote
`.claude/rules/feature-development.md` with only the non-default answers.

- A. Which branch base and naming convention? -> `feature/<slug>` off `master`.
- B. How should tests be written during implementation? -> Assert-in-the-loop: Claude scaffolds
  each test, I write the assertions.
- C. How should commits be shaped? -> Checkpoint after each green, curate before review.

**Verdict:** accepted

---

## 2. Set up the code-review skill

> set up code-review

**What came back:** Detected the RSpec suite, RuboCop/Brakeman CI, and that there is no git
remote. Wrote `.claude/rules/code-review.md`. It also spotted that `bin/ci` runs `bin/rails test`
(minitest) while the suite is RSpec, so CI never runs the specs.

- A. Where should review output go? -> Print to the terminal, since there is no remote.
- B. How to check the build? -> Run `bin/ci`.
- C. A GitHub Actions workflow for automated review? -> Skipped for now.

**Verdict:** accepted

---

## 3. Understand the codebase

> Don't write any code yet. Read the codebase and tell me what you understand from it.

**What came back:** explained architecture and the flow. A few things flagged but mentioned
they're not that important so no need to fix.

**Verdict:** accepted

---

## 4. Frame the Comment Create Mutation

> use the feature-development skill. These are the requirements for the feature: pasted the
> Create Comment Mutation part from the requirements. Just explore the codebase first and stop.
> We will make a plan after that.

**Why:** I asked this so claude can have a general idea of what the feature will be so it can
make the plan better.

**What came back:** Framed the problem, ran the suite for a green baseline (9 examples), and
explored. The first question dialog was dismissed by a misclick and had to be re-asked.

- A. "Saves it against the comment for later querying" — does this feature include exposing
  comments through the GraphQL read side now, or just persisting them so a later story can query
  them? -> I chose "Persist only" because the read side is a separate feature with its own plan.
- B. How should I model a resource_description's owner, now that it can be a Tweet or a Comment?
  -> I said not sure explain to me what each option does. After I got the explanations I chose
  Polymorphic owner.

**Verdict:** re-prompted (misclicked dialog), then accepted

---

## 5. Plan the Comment Create Mutation

> Now plan it.

**What came back:** A five-step plan, each step written as a red/green pair, plus the accepted
cost of the polymorphic swap: a polymorphic column cannot carry a foreign key, so the existing
`ON DELETE CASCADE` is lost and replaced with `dependent: :destroy`.

After reading the plan I accepted it with manual edit aproval, because it reused the OpenGraph

**Verdict:** accepted

---

## 6. Review the implementation, then plan the fixes

> use the code review skill to review the last changes. Make sure that all requirements were
> implemented

**What came back:** the agent found 4 issues. I told it to make a plan for fixing them. I got
asked:

- A. Rolling back the polymorphic migration can't restore comment-owned resource descriptions —
  they have no tweet to point at. What should `down` do? -> I chose "roll back to a looser schema"

The review also reported that only 1 of the 5 planned steps had actually landed — the mutation
itself did not exist yet.

The plan came in and to me it looked like it's going to solve the issues found by the code
reviewer so I accepted it.

**Verdict:** accepted

---

## 7. Take over the assertions

> write the assertions yourself

**What came back:** The plan was implemented but it was missing the specs

**Verdict:** accepted

---

## 8. Shape the commit history

> I got asked: Seven checkpoint commits are on the branch. How should I shape them before review?
> (Nothing is pushed — there's no remote — so rewriting is safe.)

**What came back:** Three options — squash the first three, keep all seven, or squash to one.

-> I choose to keep all seven commits

**Verdict:** accepted

---

## 9. Understand the List Tweets Query

> Now lets work on the next part: List Tweets Query. I want minimal code implementation. I will
> post the requirements. Do not implement anything yet. Tell me what you understood from them and
> then we'll make a plan later: I pasted the List Tweets Query requirement.

**What came back:** The agent said: whats being asked, whI at's already in place, what actually
has to change and a couple other notes.

It also flagged that the two aliases it had deliberately dropped from `Comment` in the previous
feature were now needed, and that the schema in the requirement (`[ResourceDescription]!`) does
not match what the existing code produces (`[ResourceDescription!]!`).

**Verdict:** accepted

---

## 10. Plan the List Tweets Query

> Ok, now make the plan. Again: I want minimal code that satisfies the requirement.

**What came back:** A two-step plan: expose the fields, then kill the N+1 with one `includes`.
Chose eager-loading over the Dataloader that is already enabled in the schema, on the grounds
that it is one line instead of several classes.

- A. How should the N+1 stay fixed? -> Pin it with a spec.

**Verdict:** accepted

---

## 11. Implement the List Tweets Query

> ok, implement it. Again I want minimal code that satisfies the requirement only.

**What came back:** Four lines of code across three files, plus the query-count spec.
The spec caught the N+1 before the fix — 25 queries for two tweets against 37 for four — and
after the `includes` the count was flat at 5 across 3, 6 and 9 tweets.

**Verdict:** accepted

---

## 12. Review the List Tweets Query

> use the code review skill to review the last changes

**What came back:** Three findings, two of them confirmed by running probes rather than by
reading: a single null `title` collapsed the entire `tweets` response to `data: nil`, and the
unconditional eager-load made `tweets { uuid }` cost 5 queries where it used to cost 1. It also
noted comments came back in unspecified order.

**Verdict:** accepted

---

## 13. Fix the review findings

> 1. make the graphql fields nullable 2. specifiy comment ordering from oldest to newest

**Why:** after the feature was implemented and reviewd there were a couple findings.

**What came back:** Both fixed test-first. The nullability change turned the collapse into
graceful degradation — same probe went from `tweets returned: nil` to `tweets returned: 3`. The
ordering spec inserts the newer comment first so insertion order alone fails it.

**Verdict:** accepted

---

## Reflection

### Which prompt did the most work

The one where I gave the requirements but told it to only explore and stop. The plan came out way
better because the decisions were made before any code existed.

Second best was asking the code review to also check that all requirements were implemented.
That's how I found out only 1 of the 5 steps was actually done.

### Where I had to step in

Mostly on the decisions it couldn't make for me: how to model the owner, what the migration
rollback should do, and the two findings from the last review.

I also had to tell it to write the assertions itself.

### What I would put in CLAUDE.md

- Code implementation should always be done with minimal required code and also in a separate 
  agent to keep the context window in check.
- Tests are RSpec but `bin/ci` runs `bin/rails test`, so CI runs 0 tests. Always run
  `bundle exec rspec`.
- Fixtures with explicit uuid ids can't use label references, use the literal uuid.
- `content` is exposed as `message` and `resource_descriptions` as `resources`, new models need
  the same aliases.
- GraphQL `null: false` has to match the column, otherwise one bad row kills the whole query.
- Feature branches build on each other, master doesn't have the Comment model.

### What Claude got wrong that I almost merged anyway

The migration couldn't be rolled back once a comment owned a resource. Everything was green
because nothing in the suite rolls back a migration. Then the fix broke it the other way around
and that only showed up because the rollback was actually run.
For this I had to create bad myself. Green specs meant nothing
here.
