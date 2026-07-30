class CreateTweets < ActiveRecord::Migration[8.1]
  def change
    create_table :tweets, id: :string, primary_key: :uuid do |t|
      t.string :content

      t.timestamps
    end
  end
end
