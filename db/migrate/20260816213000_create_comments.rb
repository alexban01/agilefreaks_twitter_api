class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :string, primary_key: :uuid do |t|
      t.references :tweet, null: false, type: :string, foreign_key: { primary_key: :uuid, on_delete: :cascade }
      t.string :content

      t.timestamps
    end
  end
end
