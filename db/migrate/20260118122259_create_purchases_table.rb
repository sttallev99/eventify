class CreatePurchasesTable < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :ticket_id, null: false
      t.integer :quantity, null: false
      t.integer :total_price_cents, null: false
      t.timestamps
    end

    add_index :purchases, :user_id
    add_index :purchases, :ticket_id

    add_foreign_key :purchases, :users
    add_foreign_key :purchases, :tickets
  end
end
