class AddColumnToClinicians < ActiveRecord::Migration[7.0]
  def change
    add_column :clinicians, :organization_id, :integer
  end
end
