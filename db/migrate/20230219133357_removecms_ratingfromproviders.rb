class RemovecmsRatingfromproviders < ActiveRecord::Migration[7.0]
  def change
    remove_column :providers, :cms_rating, :float
  end
end
