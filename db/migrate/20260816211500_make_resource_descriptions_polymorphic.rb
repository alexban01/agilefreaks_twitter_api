class MakeResourceDescriptionsPolymorphic < ActiveRecord::Migration[8.1]
  def up
    add_reference :resource_descriptions, :owner, polymorphic: true, type: :string

    # a previous rollback can leave rows with a null tweet_id (see down). Their owner is
    # unrecoverable — the columns naming it were dropped — so they are discarded rather than
    # migrated to a null owner.
    execute "DELETE FROM resource_descriptions WHERE tweet_id IS NULL"

    execute "UPDATE resource_descriptions SET owner_type = 'Tweet', owner_id = tweet_id"

    change_column_null :resource_descriptions, :owner_type, false
    change_column_null :resource_descriptions, :owner_id, false

    remove_reference :resource_descriptions, :tweet
  end

  def down
    add_reference :resource_descriptions, :tweet, type: :string,
                  foreign_key: { primary_key: :uuid, on_delete: :cascade }

    execute "UPDATE resource_descriptions SET tweet_id = owner_id WHERE owner_type = 'Tweet'"

    # tweet_id stays nullable: rows owned by anything other than a Tweet have no tweet to point
    # at, and restoring the NOT NULL would abort the rollback. The recovered schema is therefore
    # looser than the one this migration replaced — a dev escape hatch, not a production rollback.
    remove_reference :resource_descriptions, :owner, polymorphic: true
  end
end
