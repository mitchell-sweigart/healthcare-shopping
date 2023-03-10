class CreateClinicianFacilityJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :clinicians, :facilities
  end
end
