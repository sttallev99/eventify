class AdminMailer < ApplicationMailer
  def low_stock_alert(ticket, remaining)
    @ticket = ticket
    @remaining = remaining

    mail to: "admin@example.org", subject: "Low stock alert for #{@ticket.event.title}"
  end
end
