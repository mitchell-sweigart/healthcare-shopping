class AddOrganizationIdToRatings < ActiveRecord::Migration[7.0]
  def change
    add_column :ratings, :organization_id, :integer
  end
end
