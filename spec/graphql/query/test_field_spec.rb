require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'testField' do
    it 'returns success' do
      query = <<~GQL
        query {
          testField
        }
      GQL

      post '/graphql', params: { query: query }

      expect(response).to have_http_status(:ok)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({ "data" => { "testField" => "Hello World!" } })
    end
  end
end
