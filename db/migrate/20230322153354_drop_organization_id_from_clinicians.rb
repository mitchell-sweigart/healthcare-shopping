class DropOrganizationIdFromClinicians < ActiveRecord::Migration[7.0]
  def change
    remove_column :clinicians, :organization_id
  end
end
