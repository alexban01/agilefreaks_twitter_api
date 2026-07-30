class Tweet < ApplicationRecord
  self.primary_key = :uuid

  alias_attribute :message, :content

  has_many :resource_descriptions

  alias_method :resources, :resource_descriptions
end
