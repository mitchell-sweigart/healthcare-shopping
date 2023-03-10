class CreateHealthPlanNetworks < ActiveRecord::Migration[7.0]
  def change
    create_table :health_plan_networks do |t|
      t.string :name
      
      t.timestamps
    end
  end
end
