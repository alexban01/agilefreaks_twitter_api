# frozen_string_literal: true

module Mutations
  class TweetCreate < Mutations::BaseMutation
    argument :content, String, required: true

    field :tweet, Types::Tweet, null: false

    def resolve(content:)
      tweet = Tweet.create!(
        uuid: SecureRandom.uuid,
        content: content
      )

      OpenGraphScrapperJob.perform_later(tweet_id: tweet.id)

      {
        tweet: tweet
      }
    end
  end
end
