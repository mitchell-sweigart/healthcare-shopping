class CreateFacility < ActiveRecord::Migration[7.0]
  def change
    create_table :facilities do |t|
      t.string "name"
      t.string "address_line_one"
      t.string "address_line_two"
      t.string "address_city"
      t.string "address_state"
      t.string "address_zip_code"
      t.integer "npi"
      t.integer "org_PAC_ID"
      t.integer "facility_id"
      t.string "facility_type"
      t.string "overall_rating"
      t.float "latitude"
      t.float "longitude"

      t.timestamps
    end
  end
end