class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.integer :org_PAC_ID
      t.integer :num_org_members
      t.string :address_line_one
      t.string :address_line_two
      t.string :address_city
      t.string :address_state
      t.string :address_zip
      t.integer :phone_number

      t.timestamps
    end
  end
end
