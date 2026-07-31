# frozen_string_literal: true

module Types
  class Tweet < Types::BaseObject
    field :uuid, ID, null: false
    field :message, String, null: false
    field :resources, [ Types::ResourceDescription ], null: false
  end
end
