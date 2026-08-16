# code-review

- **Output:** print the review to the terminal. No remote is configured, so there are no PR
  comments to post and no prior review state to fetch — every run is a first review.
- **Build verification:** run `bin/ci`. Note it currently runs `bin/rails test` (minitest)
  while the suite is RSpec under `spec/`, so specs are not actually executed by it — run
  `bundle exec rspec` as well until `config/ci.rb` is fixed.
- **Style:** RuboCop (`rubocop-rails-omakase`) already enforces style; don't repeat its nits.
