require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'commentCreate' do
    fixtures :tweets

    let(:tweet) { tweets(:twelve_ft) }

    let(:query) do
      <<~GQL
        mutation($input: CommentCreateInput!) {
            commentCreate(input: $input) {
                comment {
                    uuid
                }
            }
        }
      GQL
    end

    let(:variables) do
      {
        "input": {
          "tweetUuid": tweet.uuid,
          "content": "This is exactly the ladder I needed: https://12ft.io/"
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
      expect(parsed_body['data']["commentCreate"]["comment"]["uuid"]).to be_present
      expect(parsed_body['data']["commentCreate"]["comment"]["uuid"].length).to eq(36)
    end

    it 'saves a comment against the tweet' do
      expect {
        subject
      }.to change { Comment.count }.by(1)

      last_comment = Comment.last
      expect(last_comment.content).to eq("This is exactly the ladder I needed: https://12ft.io/")
      expect(last_comment.tweet).to eq(tweet)
    end

    it 'starts an OpenGraphScrapperJob' do
      expect(OpenGraphScrapperJob).to receive(:perform_later).with(anything)

      subject
    end

    context 'the tweet does not exist' do
      let(:variables) do
        {
          "input": {
            "tweetUuid": "00000000-0000-0000-0000-000000000000",
            "content": "This is exactly the ladder I needed: https://12ft.io/"
          }
        }
      end

      it 'returns an error and creates no comment' do
        expect {
          subject
        }.not_to change { Comment.count }

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['errors']).to be_present
        expect(parsed_body.dig('data', 'commentCreate')).to be_nil
      end
    end
  end
end
