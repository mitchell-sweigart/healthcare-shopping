class AddCodeIdToNegotiatedRates < ActiveRecord::Migration[7.0]
  def change
    add_column :negotiated_rates, :code_id, :integer
  end
end
