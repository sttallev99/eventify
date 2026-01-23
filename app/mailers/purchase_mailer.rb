class PurchaseMailer < ApplicationMailer
  def confirmation(purchase)
    @purchase = purchase
    mail(
      to: purchase.user.email,
      subject: "🎟️ Your ticket purchase confirmation"
    )
  end
end
