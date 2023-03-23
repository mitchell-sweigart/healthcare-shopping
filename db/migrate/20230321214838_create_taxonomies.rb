class CreateTaxonomies < ActiveRecord::Migration[7.0]
  def change
    create_table :taxonomies do |t|
      t.string :code
      t.string :taxonomy_group
      t.string :desc
      t.string :state
      t.string :license
      t.boolean :primary
      t.integer :facility_id
      t.timestamps
    end
  end
end