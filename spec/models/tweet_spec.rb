require 'rails_helper'

RSpec.describe Tweet do
  fixtures :tweets, :resource_descriptions, :images

  # resource_descriptions lost its ON DELETE CASCADE when the owner became polymorphic --
  # `dependent: :destroy` is the only thing replacing it, so it needs pinning
  describe 'destroy' do
    let(:tweet) { tweets(:ogp) }

    it 'takes its resource descriptions with it' do
      expect(tweet.resource_descriptions.count).to eq(1)

      expect { tweet.destroy }.to change { ResourceDescription.count }.by(-1)
    end
  end
end
