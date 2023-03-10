class ChangeProvidersToFacilities < ActiveRecord::Migration[7.0]
  def change
    rename_table :providers, :facilities
  end
end
