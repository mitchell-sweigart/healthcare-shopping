class AddEffectiveNpiToNegotiatedRates < ActiveRecord::Migration[7.0]
  def change
    add_column :negotiated_rates, :effective_npi, :integer
  end
end
