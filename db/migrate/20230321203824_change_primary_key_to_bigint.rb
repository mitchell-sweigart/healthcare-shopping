class ChangePrimaryKeyToBigint < ActiveRecord::Migration[7.0]
  def change
    change_column :negotiated_rates, :id, :bigint
  end
end
