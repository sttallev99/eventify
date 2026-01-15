class Ticket < ApplicationRecord
  belongs_to :event

  monetize :price_cents, with_model_currency: :currency

  validates :name, presence: true
  validates :quantity_total, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
