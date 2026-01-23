class ChangeTypeOfTheNameColumnInTickets < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE TYPE ticket_name AS ENUM ('early_bird', 'regular', 'vip');
    SQL

    change_column_default :tickets, :name, nil

    change_column_null :tickets, :name, true

    execute "TRUNCATE TABLE tickets CASCADE;"

    change_column :tickets, :name, :ticket_name,
      using: "COALESCE(name, 'regular')::ticket_name",
      null: false

    change_column_default :tickets, :name, 'regular'
  end

  def down
    change_column_default :tickets, :name, nil

    change_column :tickets, :name, :string,
      using: 'name::text',
      null: false

    change_column_default :tickets, :name, 'regular'

    execute <<~SQL
      DROP TYPE ticket_name;
    SQL
  end
end
