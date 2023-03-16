class Addhhealthplanidtonegotiatedrates < ActiveRecord::Migration[7.0]
  def change
    add_column :negotiated_rates, :health_plan_id, :integer
  end
end
