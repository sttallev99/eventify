class RenameUsersIdAndCategoriesIdInEvents < ActiveRecord::Migration[8.0]
  def change
    rename_column :events, :users_id, :user_id
    rename_column :events, :categories_id, :category_id
  end
end
