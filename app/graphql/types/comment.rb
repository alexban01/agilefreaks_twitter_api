# frozen_string_literal: true

module Types
  class Comment < Types::BaseObject
    field :uuid, ID, null: false
  end
end
