class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.references :holding
      t.decimal :shares_executed
      t.boolean :buy, default: false
      t.boolean :sell, default: false
      t.decimal :execution_price
      t.timestamps
    end
  end
end
