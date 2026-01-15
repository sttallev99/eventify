# db/seeds.rb

require "faker"

puts "🌱 Seeding database..."

# ------------------------
# Reset database (development only)
# ------------------------
if Rails.env.development?
  Comment.destroy_all
  Ticket.destroy_all
  Event.destroy_all
  Category.destroy_all
  User.destroy_all
end

# ------------------------
# Users
# ------------------------
puts "Creating users..."

admin = User.create!(
  email: "admin@example.com",
  password: "password",
  first_name: "Admin",
  last_name: "User",
  is_admin: true
)

users = 10.times.map do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name

  User.create!(
    email: Faker::Internet.unique.email,
    password: "password",
    first_name: first_name,
    last_name: last_name,
    is_admin: false
  )
end

users << admin

# ------------------------
# Categories
# ------------------------
puts "Creating categories..."

category_names = [
  "Music",
  "Tech",
  "Sports",
  "Art",
  "Food",
  "Business",
  "Education"
]

categories = category_names.map do |name|
  Category.find_or_create_by!(name: name)
end

# ------------------------
# Events with Tickets
# ------------------------
puts "Creating events with tickets..."

STATUSES = %w[draft published cancelled out_of_stock archived].freeze

events = 20.times.map do
  starts_at = Faker::Time.forward(days: 30, period: :day)
  ends_at   = starts_at + rand(1..6).hours

  event = Event.new(
    title: Faker::Marketing.buzzwords.titleize,
    location: "#{Faker::Address.city}, #{Faker::Address.country}",
    starts_at: starts_at,
    ends_at: ends_at,
    status: STATUSES.sample,
    user: users.sample,
    category: categories.sample
  )

  # Build tickets BEFORE saving to satisfy validation
  event.tickets.build(
    name: "Regular",
    description: Faker::Lorem.sentence,
    price_cents: rand(1_000..5_000),
    quantity_total: rand(50..200),
    quantity_sold: rand(0..20),
    currency: "EUR",
    sales_start_at: starts_at - 14.days,
    sales_end_at: starts_at - 1.day
  )

  event.tickets.build(
    name: "VIP",
    description: Faker::Lorem.sentence,
    price_cents: rand(6_000..15_000),
    quantity_total: rand(10..50),
    quantity_sold: rand(0..10),
    currency: "EUR",
    sales_start_at: starts_at - 30.days,
    sales_end_at: starts_at - 1.day
  )

  event.save!  # validates tickets are present and names are unique
  event
end

# ------------------------
# Comments
# ------------------------
puts "Creating comments..."

events.each do |event|
  rand(2..6).times do
    Comment.create!(
      event: event,
      user: users.sample,
      content: Faker::Lorem.paragraph(sentence_count: 2)
    )
  end
end

puts "✅ Seeding complete!"
