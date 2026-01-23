class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :ticket

  after_commit :send_confirmation, on: :create
  after_commit :send_low_stock_alert, on: :create

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def send_confirmation
    PurchaseConfirmationJob.perform_later(id)
  end

  def send_low_stock_alert
    LowStockAlertJob.perform_later(ticket_id)
  end
end
