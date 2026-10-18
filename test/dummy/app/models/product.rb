class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_many :comments, as: :commentable, dependent: :restrict_with_error

  enum :status, { draft: 0, published: 1 }

  validates :name, presence: true
end
