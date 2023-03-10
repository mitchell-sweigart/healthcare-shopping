class AddClinicianIdToUltilizations < ActiveRecord::Migration[7.0]
  def change
    add_column :utilizations, :clinician_id, :integer
  end
end
