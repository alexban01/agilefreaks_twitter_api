class ResourceDescription < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :image
end
