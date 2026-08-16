class Tweet < ApplicationRecord
  self.primary_key = :uuid

  alias_attribute :message, :content

  # polymorphic owners can't carry a foreign key, so the cascade moves into the app
  has_many :resource_descriptions, as: :owner, dependent: :destroy
  # destroyed through Rails, not the database cascade, so each comment takes its own
  # (foreign-key-less) resource descriptions with it
  has_many :comments, dependent: :destroy

  alias_method :resources, :resource_descriptions
end
