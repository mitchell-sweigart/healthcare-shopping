class FixProviderIDinServices < ActiveRecord::Migration[7.0]
  def change
    rename_column :services, :provider_id, :facility_id
  end
end
