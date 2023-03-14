class ChangeFacilityIdToString < ActiveRecord::Migration[7.0]
  def change
    change_column(:facilities, :facility_id, :string)
  end
end
