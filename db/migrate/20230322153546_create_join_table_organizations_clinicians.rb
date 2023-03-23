class CreateJoinTableOrganizationsClinicians < ActiveRecord::Migration[7.0]
  def change
    create_join_table :organizations, :clinicians do |t|
      t.integer [:organization_id, :clinician_id]
      t.integer [:clinician_id, :organization_id]
    end
  end
end
