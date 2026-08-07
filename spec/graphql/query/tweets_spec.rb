require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'tweets' do
    fixtures :tweets, :resource_descriptions, :images

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
                      "resources" => []
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
                      ]
                    })
    end
  end
end
