# frozen_string_literal: true

module Types
  class Image < Types::BaseObject
    field :url, String, null: false
    field :byte_size, Integer, null: false
  end
end
