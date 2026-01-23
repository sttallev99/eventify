class RenameTicketsNameToTicketType < ActiveRecord::Migration[8.0]
  def change
    rename_column :tickets, :name, :type
  end
end
