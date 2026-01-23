require "faker"

puts "Cleaning database..."
Purchase.delete_all
Ticket.delete_all
Event.delete_all
Category.delete_all
User.delete_all

puts "Creating users..."
users = 10.times.map do
  User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password"
  )
end

puts "Creating categories..."
categories = %w[Music Sports Tech Education].map do |name|
  Category.create!(name: name)
end

puts "Creating events with tickets..."
10.times do
  start_time = if [ true, false ].sample
  Faker::Time.backward(days: 30, period: :morning)
  else
    Faker::Time.forward(days: 30, period: :morning)
  end

  end_time = start_time + rand(1..5).days

  event = Event.new(
    title: "#{Faker::Music::RockBand.name} Live",
    location: Faker::Address.city,
    starts_at: start_time,
    ends_at: end_time,
    status: %w[draft published].sample,
    category: categories.sample,
    user: users.sample
  )

  event.save!(validate: false)

  ticket_types = Ticket.ticket_types.keys.shuffle.take(rand(1..3))

  ticket_types.each do |ticket_type|
    quantity_total = rand(50..200)
    quantity_sold  = rand(0..quantity_total)

    ticket_attrs = {
      event: event,
      ticket_type: ticket_type,
      price_cents: rand(1_000..10_000),
      quantity_total: quantity_total,
      quantity_sold: quantity_sold,
      description: Faker::Lorem.sentence
    }

    if ticket_type == "early_bird"
      sales_start = Faker::Time.forward(days: 5)
      sales_end   = sales_start + rand(2..7).days

      ticket_attrs.merge!(
        sales_start_at: sales_start,
        sales_end_at: sales_end
      )
    end

    Ticket.create!(ticket_attrs)
  end

  event.reload
end

puts "Creating purchases..."
Ticket.all.sample(20).each do |ticket|
  quantity = rand(1..5)

  Purchase.create!(
    ticket: ticket,
    user: users.sample,
    quantity: quantity,
    total_price_cents: ticket.price_cents * quantity
  )
end

puts "Creating comments..."
Event.all.sample(15).each do |event|
  Comment.create!(
    event: event,
    user: users.sample,
    content: Faker::Lorem.sentence
  )
end

puts "✅ Seed data created successfully!"
