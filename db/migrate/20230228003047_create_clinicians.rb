class CreateClinicians < ActiveRecord::Migration[7.0]
  def change
    create_table :clinicians do |t|
      t.integer :npi
      t.integer :ind_PAC_ID
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :suffix
      t.string :credential
      t.string :medical_school
      t.integer :graduation_year
      t.string :primary_speciality
      t.string :secondary_speciality_1
      t.string :secondary_speciality_2
      t.string :secondary_speciality_3
      t.string :secondary_speciality_4

      t.timestamps
    end
  end
end
