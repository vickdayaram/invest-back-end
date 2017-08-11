class User < ApplicationRecord
  has_secure_password
  has_many :accounts
  has_many :holdings, through: :accounts
  has_many :transactions, through: :holdings

  def format_json
    data = {:accounts => []}
    #iterating through and constructing the object here
    data.each do |key, value|
      self.accounts.each do |account|
        value.push({:account => account, :holdings => []})
      end
    end

    #doing one more iteration and filling in the holdings and transactions
    data.each do |key, value|
      value.each do |object|
          self.accounts.each do |account|
            if object[:account].id === account.id
              sorted = account.holdings.sort_by{ |holding| holding.id}
                sorted.each do |holding|
                  object.values[1].push({:holding => holding, :transactions => holding.transactions})
            end
          end
        end
      end
    end

    data[:username] = self.username
    return data
  end

  def create_account(type, deposit)
    account = Account.new(account_type: type)
    account.account_number = account.generate_account_number
    money_market = Holding.create(name: "Money Marketfund", symbol: "MM", shares: deposit)
    money_market.transactions << Transaction.create(buy: true, execution_price: 1)
    account.holdings << money_market
    self.accounts << account
    return self
  end
end
