class Category < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :name, presence: true, uniqueness: { message: "Category name must be unique" }
end
