require 'rails_helper'

RSpec.describe OpenGraphScrapperJob do
  fixtures :tweets

  describe 'perform' do
    subject { OpenGraphScrapperJob.new.perform(tweet_id: tweet.id) }

    context 'tweet content contains an URL' do
      let(:tweet) { tweets(:ogp) }

      context 'URL defines an OpenGraph resource' do
        before do
          stub_request(:get, 'https://ogp.me/')
            .to_return(body: File.read('./spec/fixtures/ogp.me/success.html'), status: 200)
        end

        it 'creates a ResourceDescription' do
          expect { subject }.to change { ResourceDescription.count }.by(1)

          resource_description = tweet.resource_descriptions.first
          expect(resource_description.title).to eq 'Open Graph protocol'
          expect(resource_description.description).to eq 'The Open Graph protocol enables any web page to become a rich object in a social graph.'
          expect(resource_description.url).to eq 'https://ogp.me/'
          expect(resource_description.image.url).to eq 'https://ogp.me/logo.png'
          expect(resource_description.image.byte_size).to eq(42)
        end
      end
    end
  end
end
