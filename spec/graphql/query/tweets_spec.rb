require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'tweets' do
    fixtures :tweets, :comments, :resource_descriptions, :images

    let(:query) do
      <<~GQL
        query {
          tweets {
              uuid
              message
              resources {
                  title
                  description
                  url
                  image {
                      url
                  }
              }
              comments {
                  uuid
                  message
                  resources {
                      title
                      description
                      url
                      image {
                          url
                      }
                  }
              }
          }
        }
      GQL
    end

    it 'returns success' do
      tweet = tweets(:twelve_ft)

      post '/graphql', params: { query: query }

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig('data', 'tweets').size).to eq(Tweet.count)
      expect(parsed_body.dig('data', 'tweets'))
        .to include({
                      "uuid" => tweet.uuid,
                      "message" => tweet.content,
                      "resources" => [],
                      "comments" => []
                    })
    end

    it 'returns the resource descriptions of a tweet' do
      tweet = tweets(:ogp)
      resource_description = resource_descriptions(:ogp)

      post '/graphql', params: { query: query }

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body.dig('data', 'tweets'))
        .to include({
                      "uuid" => tweet.uuid,
                      "message" => tweet.content,
                      "resources" => [
                        {
                          "title" => resource_description.title,
                          "description" => resource_description.description,
                          "url" => resource_description.url,
                          "image" => { "url" => resource_description.image.url }
                        }
                      ],
                      "comments" => []
                    })
    end

    it 'returns the comments of a tweet, resources and all' do
      tweet = tweets(:plain)
      comment = comments(:scrapped)
      resource_description = resource_descriptions(:ogp_comment)

      post '/graphql', params: { query: query }

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      commented_tweet = parsed_body.dig('data', 'tweets').find { |t| t["uuid"] == tweet.uuid }

      expect(commented_tweet["comments"])
        .to include({
                      "uuid" => comment.uuid,
                      "message" => comment.content,
                      "resources" => [
                        {
                          "title" => resource_description.title,
                          "description" => resource_description.description,
                          "url" => resource_description.url,
                          "image" => { "url" => resource_description.image.url }
                        }
                      ]
                    })
    end
  end
end
