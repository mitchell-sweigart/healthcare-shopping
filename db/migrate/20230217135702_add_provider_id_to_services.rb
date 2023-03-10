class AddProviderIdToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :facility_id, :integer
    add_index :services, :facility_id
  end
end
