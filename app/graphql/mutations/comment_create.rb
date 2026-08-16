# frozen_string_literal: true

module Mutations
  class CommentCreate < Mutations::BaseMutation
    argument :tweet_uuid, ID, required: true
    argument :content, String, required: true

    field :comment, Types::Comment, null: false

    def resolve(tweet_uuid:, content:)
      comment = Comment.create!(
        uuid: SecureRandom.uuid,
        tweet: Tweet.find_by(uuid: tweet_uuid),
        content: content
      )

      {
        comment: comment
      }
    end
  end
end
