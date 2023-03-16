class Changehealthplanidtostring < ActiveRecord::Migration[7.0]
  def change
    change_column(:negotiated_rates, :health_plan_id, :string)
  end
end
