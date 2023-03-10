class AddOrgPacIdToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :org_PAC_ID, :integer
  end
end
