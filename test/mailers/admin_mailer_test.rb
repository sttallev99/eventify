require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  test "low_stock_alert" do
    mail = AdminMailer.low_stock_alert
    assert_equal "Low stock alert", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
