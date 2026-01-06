class Event < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_one :ticket, dependent: :destroy
  has_many :comment, dependent: :destroy
  validates_associated :ticket
  validates_associated :comment

  has_many_attached :images
  has_rich_text :description

  validates :title, :location, :starts_at, :published, presence: true
  validates :ends_at, presence: true, comparison: { greater_than: :starts_at }
end
