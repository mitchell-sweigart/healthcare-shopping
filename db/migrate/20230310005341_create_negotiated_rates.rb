class CreateNegotiatedRates < ActiveRecord::Migration[7.0]
  def change
    create_table :negotiated_rates do |t|

      t.string :billing_code
      t.string :billing_code_type
      t.string :negotiation_arrangement
      t.string :negotiated_type
      t.decimal :negotiated_rate
      t.date :experation_date
      t.string :billing_class
      t.text :service_code, default: [].to_yaml
      t.text :billing_code_modifier, default: [].to_yaml
      t.integer :tin
      t.string :tin_type
      t.integer :npi

      t.timestamps
    end
  end
end