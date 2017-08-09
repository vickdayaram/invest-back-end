class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.references :holding
      t.boolean :buy, default: false
      t.boolean :sell, default: false
      t.integer :execution_price
      t.timestamps
    end
  end
end
