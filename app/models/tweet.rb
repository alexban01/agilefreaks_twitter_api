class Tweet < ApplicationRecord
  self.primary_key = :uuid

  alias_attribute :message, :content

  # polymorphic owners can't carry a foreign key, so the cascade moves into the app
  has_many :resource_descriptions, as: :owner, dependent: :destroy

  alias_method :resources, :resource_descriptions
end
