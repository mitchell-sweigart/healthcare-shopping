class CreateIdentifiers < ActiveRecord::Migration[7.0]
  def change
    create_table :identifiers do |t|
      t.timestamps
    end
  end
end