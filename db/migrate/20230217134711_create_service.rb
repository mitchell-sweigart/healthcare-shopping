class CreateService < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.string :name
      t.string :cpt_hcpcs
      t.decimal :gross_charge
      t.decimal :self_pay_cash_price
      t.decimal :aetna_commercial
      t.decimal :aetna_asa
      t.decimal :cbc_commercial
      t.decimal :cigna
      t.decimal :geisinger_commercial
      t.decimal :highmark_choice_blue
      t.decimal :highmark_commercial
      t.decimal :multiplan
      t.decimal :uhc_commercial
      t.decimal :upmc_commercial
      t.decimal :wellspan
      t.integer :facility_id
      
      t.timestamps
    end
  end
end
