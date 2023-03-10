class RemoveNameAndCptFromServices < ActiveRecord::Migration[7.0]
  def change
    remove_column :services, :name, :string
    remove_column :services, :cpt_hcpcs, :string
  end
end
