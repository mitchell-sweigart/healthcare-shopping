class CreateUtilizations < ActiveRecord::Migration[7.0]
  def change
    create_table :utilizations do |t|
      t.integer :hcpcs_code
      t.string :hcpcs_description
      t.integer :service_count
      t.integer :beneficiary_count

      t.timestamps
    end
  end
end
