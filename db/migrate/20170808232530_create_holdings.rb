class CreateHoldings < ActiveRecord::Migration[5.1]
  def change
    create_table :holdings do |t|
      t.references :account
      t.string :name
      t.string :symbol
      t.integer :shares, default: 0
      t.integer :current_price
      t.timestamps
    end
  end
end
