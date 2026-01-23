class LowStockAlertJob < ApplicationJob
  queue_as :default

  LOW_STOCK_THRESHOLD = 10

  def perform(ticket_id)
    ticket = Ticket.find_by(id: ticket_id)
    return unless ticket # stop if ticket doesn't exist

    remaining = ticket.quantity_total - ticket.quantity_sold
    return unless remaining <= LOW_STOCK_THRESHOLD

    AdminMailer.low_stock_alert(ticket, remaining).deliver_now
  end
end
