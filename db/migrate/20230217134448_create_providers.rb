class CreateProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :address_line_one
      t.string :address_line_two
      t.string :address_city
      t.string :address_state
      t.string :address_zip_code
      t.float :cms_rating
      t.integer :npi

      t.timestamps
    end
  end
end
