# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/low_stock_alert
  def low_stock_alert
    AdminMailer.low_stock_alert
  end
end
