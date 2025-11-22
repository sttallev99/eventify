class Event < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_one :tickets, dependent: :destroy
  has_many :comments, dependent: :destroy
end
