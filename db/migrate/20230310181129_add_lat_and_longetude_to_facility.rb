class AddLatAndLongetudeToFacility < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :latitude, :float
    add_column :facilities, :longitude, :float
  end
end
