class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.text :content, null: false
      t.references :event, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
