class Api::V1::TicketsController < Api::V1::BaseController
  before_action :authenticate_request

  def buy
    ticket = Ticket.find(params[:ticket_id])

    Ticket.transaction do
      ticket.lock!

      quantity = params[:quantity].to_i
      available = ticket.quantity_total - ticket.quantity_sold

      if available < quantity
        return render json: { error: "Only #{available} tickets left" }, status: :unprocessable_entity
      end

      ticket.quantity_sold += quantity
      ticket.save!

      render json: { message: "Purchased #{quantity} tickets successfully" }
    end
  end
end
