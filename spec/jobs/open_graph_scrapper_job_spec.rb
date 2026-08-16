require 'rails_helper'

RSpec.describe OpenGraphScrapperJob do
  fixtures :tweets, :comments

  describe 'perform' do
    subject { OpenGraphScrapperJob.new.perform(owner) }

    context 'tweet content contains an URL' do
      let(:owner) { tweets(:unscrapped) }

      context 'URL defines an OpenGraph resource' do
        before do
          stub_request(:get, 'https://ogp.me/')
            .to_return(body: File.read('./spec/fixtures/ogp.me/success.html'), status: 200)
          stub_request(:head, 'https://ogp.me/logo.png')
            .to_return(headers: { 'Content-Length' => '1234' }, status: 200)
        end

        it 'creates a ResourceDescription' do
          expect { subject }.to change { ResourceDescription.count }.by(1)

          resource_description = owner.resource_descriptions.first
          expect(resource_description.title).to eq 'Open Graph protocol'
          expect(resource_description.description).to eq 'The Open Graph protocol enables any web page to become a rich object in a social graph.'
          expect(resource_description.url).to eq 'https://ogp.me/'
          expect(resource_description.image.url).to eq 'https://ogp.me/logo.png'
          expect(resource_description.image.byte_size).to eq(1234)
        end
      end

      context 'URL defines no OpenGraph metadata' do
        before do
          stub_request(:get, 'https://ogp.me/').to_return(body: '<html><head></head></html>', status: 200)
        end

        it 'creates no ResourceDescription' do
          expect { subject }.not_to change { ResourceDescription.count }
        end
      end

      context 'URL is unreachable' do
        before do
          stub_request(:get, 'https://ogp.me/').to_timeout
        end

        it 'creates no ResourceDescription and does not raise' do
          expect { subject }.not_to change { ResourceDescription.count }
        end
      end
    end

    context 'comment content contains an URL' do
      let(:owner) { comments(:unscrapped) }

      before do
        stub_request(:get, 'https://ogp.me/')
          .to_return(body: File.read('./spec/fixtures/ogp.me/success.html'), status: 200)
        stub_request(:head, 'https://ogp.me/logo.png')
          .to_return(headers: { 'Content-Length' => '1234' }, status: 200)
      end

      # the same job scraps comments, there is no second implementation
      it 'creates a ResourceDescription owned by the comment' do
        expect { subject }.to change { ResourceDescription.count }.by(1)

        resource_description = owner.resource_descriptions.first
        expect(resource_description.title).to eq 'Open Graph protocol'
        expect(resource_description.url).to eq 'https://ogp.me/'
        expect(resource_description.image.byte_size).to eq(1234)
      end
    end

    context 'tweet content contains no URL' do
      let(:owner) { tweets(:plain) }

      it 'creates no ResourceDescription' do
        expect { subject }.not_to change { ResourceDescription.count }
      end
    end
  end
end
