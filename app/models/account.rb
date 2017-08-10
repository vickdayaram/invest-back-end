class Account < ApplicationRecord
  has_many :holdings
  has_many :transactions, through: :holdings
end
