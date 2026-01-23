class PurchaseConfirmationJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = Purchase.includes(:user, ticket: :event).find(purchase_id)

    PurchaseMailer.confirmation(purchase).deliver_now
  end
end
