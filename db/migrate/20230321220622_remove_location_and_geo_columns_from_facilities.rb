class RemoveLocationAndGeoColumnsFromFacilities < ActiveRecord::Migration[7.0]
  def change
    remove_column :facilities, :address_line_one
    remove_column :facilities, :address_line_two
    remove_column :facilities, :address_city
    remove_column :facilities, :address_state
    remove_column :facilities, :address_zip_code
    remove_column :facilities, :latitude
    remove_column :facilities, :longitude
  end
end
