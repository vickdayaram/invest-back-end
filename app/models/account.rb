class Account < ApplicationRecord
  has_many :holdings
  has_many :transactions, through: :holdings

  @@account_numbers = (1000000..2000000).to_a.shuffle

  def generate_account_number
    @@account_numbers.pop
  end
end
