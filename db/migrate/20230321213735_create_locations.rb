class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.integer :postal_code
      t.string :telephone_number
      t.string :fax_number
      t.integer :facility_id
      t.timestamps
    end
  end
end
