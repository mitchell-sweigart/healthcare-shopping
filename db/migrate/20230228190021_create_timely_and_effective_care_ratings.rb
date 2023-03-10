class CreateTimelyAndEffectiveCareRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :timely_and_effective_care_ratings do |t|

      t.string :condition
      t.string :measure_id
      t.string :measure_name
      t.string :score
      t.string :sample
      t.integer :facility_id

      t.timestamps
    end
  end
end
