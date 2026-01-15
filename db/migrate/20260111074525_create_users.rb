class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
