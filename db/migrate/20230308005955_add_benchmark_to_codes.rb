class AddBenchmarkToCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :codes, :benchmark_cost, :float
  end
end
