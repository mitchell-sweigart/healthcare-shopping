class AddCodeIdToService < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :code_id, :integer
    add_index :services, :code_id
  end
end
