class CreateResourceDescriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :resource_descriptions do |t|
      t.references :tweet, null: false, type: :string, foreign_key: { primary_key: :uuid, on_delete: :cascade }
      t.references :image, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.string :url

      t.timestamps
    end
  end
end
