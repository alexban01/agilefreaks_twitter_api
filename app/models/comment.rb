class Comment < ApplicationRecord
  self.primary_key = :uuid

  belongs_to :tweet, primary_key: :uuid

  # polymorphic owners can't carry a foreign key, so the cascade moves into the app
  has_many :resource_descriptions, as: :owner, dependent: :destroy
end
