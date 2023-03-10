class AddOverallRatingToFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :overall_rating, :string
  end
end
