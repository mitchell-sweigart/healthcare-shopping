class AddProviderIdToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :provider_id, :integer
    add_index :services, :provider_id
  end
end
