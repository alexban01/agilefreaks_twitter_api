class ResourceDescription < ApplicationRecord
  belongs_to :tweet, primary_key: :uuid
  belongs_to :image
end
