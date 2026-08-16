class MakeResourceDescriptionsPolymorphic < ActiveRecord::Migration[8.1]
  def up
    add_reference :resource_descriptions, :owner, polymorphic: true, type: :string

    execute "UPDATE resource_descriptions SET owner_type = 'Tweet', owner_id = tweet_id"

    change_column_null :resource_descriptions, :owner_type, false
    change_column_null :resource_descriptions, :owner_id, false

    remove_reference :resource_descriptions, :tweet
  end

  def down
    add_reference :resource_descriptions, :tweet, type: :string,
                  foreign_key: { primary_key: :uuid, on_delete: :cascade }

    execute "UPDATE resource_descriptions SET tweet_id = owner_id WHERE owner_type = 'Tweet'"

    change_column_null :resource_descriptions, :tweet_id, false

    remove_reference :resource_descriptions, :owner, polymorphic: true
  end
end
