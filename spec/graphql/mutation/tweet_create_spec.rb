require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'tweetCreate' do
    let(:query) do
      <<~GQL
        mutation($input: TweetCreateInput!) {
            tweetCreate(input: $input) {
                tweet {
                    uuid
                }
            }
        }
      GQL
    end

    let(:variables) do
      {
        "input": {
          "content": "Best thing I found in a while: https://12ft.io/"
        }
      }
    end

    subject do
      post '/graphql', params: { query: query, variables: variables }
    end

    it 'returns success' do
      subject

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['data']["tweetCreate"]["tweet"]["uuid"]).to be_present
      expect(parsed_body['data']["tweetCreate"]["tweet"]["uuid"].length).to eq(36)
    end

    it 'saves a tweet in the database' do
      expect {
        subject
      }.to change { Tweet.count }.by(1)

      last_tweet = Tweet.last
      expect(last_tweet).to be_present
      expect(last_tweet.content).to eq("Best thing I found in a while: https://12ft.io/")
    end

    it 'starts an OpenGraphScrapperJob' do
      expect(OpenGraphScrapperJob).to receive(:perform_later).with(anything)

      subject
    end
  end
end
