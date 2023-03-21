class ChangeClinicianIntegersToBigInts < ActiveRecord::Migration[7.0]
  def change
    change_column :clinicians, :npi, :bigint
    change_column :clinicians, :ind_PAC_ID, :bigint
  end
end
