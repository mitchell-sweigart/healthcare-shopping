class RemoveClinicianIdFromFacilities < ActiveRecord::Migration[7.0]
  def change
    remove_column :facilities, :clinician_id
  end
end
