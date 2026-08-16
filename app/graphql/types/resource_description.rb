# frozen_string_literal: true

module Types
  class ResourceDescription < Types::BaseObject
    # nullable because the columns are: an incomplete row degrades to null fields
    # instead of nulling the whole query
    field :title, String, null: true
    field :description, String, null: true
    field :url, String, null: true
    # image_id is NOT NULL, so this one can promise
    field :image, Types::Image, null: false
  end
end
