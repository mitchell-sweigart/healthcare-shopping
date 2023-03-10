class AddFacilityAndProviderIdToNegotiatedRates < ActiveRecord::Migration[7.0]
  def change
    add_column :negotiated_rates, :facility_id, :integer
    add_column :negotiated_rates, :clinician_id, :integer
  end
end
