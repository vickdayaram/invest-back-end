class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.string :age
      t.string :goal
      t.string :risk_tolerance
      t.string :current_portfolio
      t.timestamps
    end
  end
end
