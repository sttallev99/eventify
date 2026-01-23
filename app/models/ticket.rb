class Ticket < ApplicationRecord
  enum :ticket_type, {
    early_bird: "early_bird",
    regular: "regular",
    vip: "vip"
  }, prefix: true

  after_commit :send_low_stock_alert, on: :create

  has_many :purchases, dependent: :destroy
  belongs_to :event

  monetize :price_cents, with_model_currency: :currency

  validates :ticket_type, presence: true
  validates :quantity_total, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :sales_start_at, :sales_end_at, presence: true, if: :early_bird?

  def available_quantity
    quantity_total - quantity_sold
  end

  def early_bird?
    ticket_type === "early_bird"
  end

  def send_low_stock_alert
    LowStockAlertJob.perform_later(id)
  end
end
