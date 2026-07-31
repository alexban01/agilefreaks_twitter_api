# frozen_string_literal: true

module Types
  class ResourceDescription < Types::BaseObject
    field :title, String, null: false
    field :description, String, null: false
    field :url, String, null: false
    field :image, Types::Image, null: false
  end
end
