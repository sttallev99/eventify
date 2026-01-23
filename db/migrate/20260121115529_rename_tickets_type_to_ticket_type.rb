class RenameTicketsTypeToTicketType < ActiveRecord::Migration[8.0]
  def change
    rename_column :tickets, :type, :ticket_type
    remove_index :tickets, column: [ :event_id, :ticket_type ] rescue nil
    add_index :tickets, [ :event_id, :ticket_type ], unique: true, name: "index_tickets_on_event_id_and_ticket_type"
  end
end
