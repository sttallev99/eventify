class AddAndRenameFieldsToTickets < ActiveRecord::Migration[8.0]
  def change
    rename_column :tickets, :price, :price_cents
    change_column :tickets, :price_cents, :integer, null: false, default: 0

    rename_column :tickets, :quantity, :quantity_total

    add_column :tickets, :quantity_sold, :integer, null: false, default: 0
    add_column :tickets, :name, :string, null: false, default: "Regular"
    add_column :tickets, :description, :text
    add_column :tickets, :sales_start_at, :datetime
    add_column :tickets, :sales_end_at, :datetime

    add_index :tickets, [ :event_id, :name ], unique: true

    add_check_constraint :tickets, "price_cents >= 0", name: "price_cents_non_negative"
    add_check_constraint :tickets, "quantity_total >= 0", name: "qty_total_non_negative"
    add_check_constraint :tickets, "quantity_sold >= 0", name: "qty_sold_non_negative"
    add_check_constraint :tickets, "quantity_sold <= quantity_total", name: "qty_sold_not_exceed_total"
  end
end
