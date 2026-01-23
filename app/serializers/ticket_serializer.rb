class TicketSerializer < ActiveModel::Serializer
  attributes :id, :ticket_type, :price_cents, :currency, :available_quantity

  def available_quantity
    object.quantity_total - object.quantity_sold
  end
end
