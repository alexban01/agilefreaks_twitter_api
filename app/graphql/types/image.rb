# frozen_string_literal: true

module Types
  class Image < Types::BaseObject
    field :url, String, null: true
    field :byte_size, Integer, null: true
  end
end
