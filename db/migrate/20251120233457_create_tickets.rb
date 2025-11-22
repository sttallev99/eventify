class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.decimal :price, null: false
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
