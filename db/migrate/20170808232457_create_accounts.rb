class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.references :user
      t.integer :account_number
      t.string :account_type
      t.timestamps
    end
  end
end
