class AddReferenceFields < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :users, null: false, foreign_key: true
    add_reference :events, :categories, null: false, foreign_key: true
    add_reference :tickets, :events, null: false, foreign_key: true
    add_reference :comments, :events, null: false, foreign_key: true
    add_reference :comments, :users, null: false, foreign_key: true
  end
end
