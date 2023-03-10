class FixProviderIDinRatings < ActiveRecord::Migration[7.0]
  def change
    rename_column :ratings, :provider_id, :facility_id
  end
end
