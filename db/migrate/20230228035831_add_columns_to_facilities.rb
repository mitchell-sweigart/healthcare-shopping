class AddColumnsToFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :facility_id, :integer
    add_column :facilities, :facility_type, :string
  end
end
