class AddDbaNameToFacilities < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :organization_dba_name, :string
  end
end
