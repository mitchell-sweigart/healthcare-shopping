class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.string :measure_cd
      t.string :measure_title
      t.integer :star_value
      t.integer :provider_id

      t.timestamps
    end
  end
end
