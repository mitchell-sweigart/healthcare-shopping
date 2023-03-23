class AddColumnsToIdentifiersTable < ActiveRecord::Migration[7.0]
  def change
    add_column :identifiers, :code, :string
    add_column :identifiers, :desc, :string
    add_column :identifiers, :issuer, :string
    add_column :identifiers, :identifier, :string
    add_column :identifiers, :state, :string
    add_column :identifiers, :facility_id, :integer
  end
end