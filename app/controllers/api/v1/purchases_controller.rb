class Api::V1::PurchasesController < Api::V1::BaseController
  def show
    event = Event.includes(:tickets, :category, comments: :user).find(params[:id])

    render json: event, serializer: EventSerializer
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Event not found" }, status: :not_found
  end

  def create
    ticket = Ticket.find(params[:ticket_id])
    quantity = params[:quantity].to_i

    if quantity <= 0
      return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity
    end

    available_quantity = ticket.quantity_total - ticket.quantity_sold
    if available_quantity < quantity
      return render json: { error: "Not enough tickets available" }, status: :unprocessable_entity
    end

    total_price_cents = ticket.price_cents * quantity
    purchase = nil

    Ticket.transaction do
      # lock row to prevent race conditions
      ticket.lock!

      available_quantity = ticket.quantity_total - ticket.quantity_sold
      if available_quantity < quantity
        raise ActiveRecord::Rollback
      end

      ticket.increment!(:quantity_sold, quantity)

      # ✅ SOLD OUT CHECK (schema-safe)
      event = ticket.event

      tickets_still_available = event.tickets
        .where("quantity_total - quantity_sold > 0")
        .exists?

      unless tickets_still_available
        event.update_column(:status, "out_of_stock")
      end

      purchase = current_user.purchases.create!(
        ticket: ticket,
        quantity: quantity,
        total_price_cents: total_price_cents
      )
    end

    render json: purchase, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
