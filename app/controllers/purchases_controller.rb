class PurchasesController < ApplicationController
  before_action :require_login

  def index
    @purchases = Purchase.includes(:user, :ticket, ticket: :event).order(created_at: :desc)
    @columns = [
      { header: "User", attribute: :user_id },
      { header: "Ticket", attribute: :ticket_id },
      { header: "Purchased At", value: ->(event) { event.created_at.strftime("%b %d, %Y") } },
      { header: "Quantity", attribute: :quantity }
    ]
  end
end
