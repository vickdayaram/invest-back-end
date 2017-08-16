class User < ApplicationRecord
  has_secure_password
  has_many :accounts
  has_many :holdings, through: :accounts
  has_many :transactions, through: :holdings

  attr_accessor :portfolio_allocation

  def portfolio_holdings
    holdings = []
    self.holdings.each do |holding|
      holdings.push({holding.symbol => holding.shares})
    end
    sum_of_holdings = holdings.inject{|a,b| a.merge(b){|_,x,y| x + y}}
    sum_of_holdings
  end

  def portfolio_total_and_allocation
    @holding = Holding.new
    holdings = self.portfolio_holdings
    holdings_by_dollars = []
    total = 0
    holdings.each do |key, value|
      if key === "MM"
        holdings_by_dollars.push({key => (1 * value.to_f).to_f})
        total += (1 * value.to_f).to_f
      else
        price = @holding.get_price(key).to_f
        holdings_by_dollars.push({key => (price * value.to_f).to_f})
        total += (price * value.to_f)
      end
    end
    total = '%.2f' % [(total * 100).round / 100.0]
    return {portfolio_total: total, username: self.username, allocation: holdings_by_dollars}
  end

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

    return data
  end

  def create_account(type, deposit)
    account = Account.create(account_type: type)
    account.account_number = account.generate_account_number
    money_market = Holding.create(name: "Money Marketfund", symbol: "MM", shares: deposit)
    money_market.transactions << Transaction.create(buy: true, execution_price: 1, shares_executed: deposit)
    account.holdings << money_market
    self.accounts << account
    return self
  end

  def get_transactions
    transactions_by_account = {}
    self.accounts.each do |account|
      key = account.account_type + " " + account.account_number.to_s
      transactions_by_account[key] = []
    end
    self.accounts.each do |account|
      account.transactions.each do |transaction|
        key = account.account_type + " " + account.account_number.to_s
        transactions_by_account[key].push(
        {holding: transaction.holding.symbol,
         buy: transaction.buy,
         sell: transaction.sell,
         price: transaction.execution_price,
         date: transaction.created_at,
         shares: transaction.shares_executed})
      end
    end
    return transactions_by_account
  end
end
