# frozen_string_literal: true

module Resolvers
  class Tweets < BaseResolver
    type [ Types::Tweet ], null: false

    def resolve
      Tweet.includes(resource_descriptions: :image, comments: { resource_descriptions: :image })
    end
  end
end
