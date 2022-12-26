class AddProductionDateAndExpireationDateToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :produced_at, :date
    add_column :products, :expires_at, :date
  end
end
