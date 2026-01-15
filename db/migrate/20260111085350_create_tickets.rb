class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets, id: :uuid do |t|
      t.decimal :price, null: false, precision: 10, scale: 2
      t.integer :quantity, null: false
      t.references :event, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
