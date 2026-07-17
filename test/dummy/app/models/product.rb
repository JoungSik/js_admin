class Product < ApplicationRecord
  belongs_to :category, optional: true

  enum :status, { draft: 0, published: 1 }

  validates :name, presence: true
end
