class User < ApplicationRecord
  has_secure_password
  validates :username, uniqueness: true, length: {:within => 4..12}, presence: true
  validates :password, presence: true, length: {:within => 6..1024}
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
    total_contributions = get_total_portfolio_contributions
    total = '%.2f' % [(total * 100).round / 100.0]
    return {portfolio_total: total, username: self.username, allocation: holdings_by_dollars, total_contributions: total_contributions}
  end

  #currently not using this method, tried to optimize but it did not work
  def get_portfolio_symbols_and_prices
    holdings = self.portfolio_holdings
    @holding = Holding.new
    symbol_and_price = []
    holdings.each do |key, value|
      if key === "MM"
        symbol_and_price.push({key => 1})
      else
        price = @holding.get_price(key).to_f
        symbol_and_price.push({key => price})
      end
    end
    symbol_and_price
  end

  def get_total_portfolio_contributions
    total_contributions = 0
    self.accounts.each do |account|
      total_contributions += account.transactions.first.shares_executed.to_i
    end
    total_contributions
  end

  def make_json_data_object
    data = {:accounts => []}
    data.each do |key, value|
      self.accounts.each do |account|
        value.push({:account => account, :holdings => []})
      end
    end
    data
  end


  def format_json
    data = make_json_data_object
    @holding = Holding.new
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

  #currently not using this method, tried to optimize but it did not work
  def get_price_locally(symbol)
    symbol_and_prices = get_portfolio_symbols_and_prices
    symbol_and_prices.each do |symbol_and_price_object|
      symbol_and_price_object.each do |symbolmatch, price|
        if symbol === symbolmatch
          return price
        end
      end
    end
  end

  def get_account_performance
    data = make_json_data_object
    @holding = Holding.new
    data.each do |key, value|
      value.each do |account_object|
          self.accounts.each do |account|
            if account_object[:account].id === account.id
              sorted = account.holdings.sort_by{ |holding| holding.id}
                sorted.each do |holding|
                  if holding.symbol === "MM"
                    value = holding.shares
                  else
                    symbol = holding.symbol
                    price = @holding.get_price(symbol).to_f
                    shares = holding.shares
                    value = (price * shares).to_f
                  end
                  value = '%.2f' % [(value * 100).round / 100.0]
                  account_object.values[1].push({:holding => holding, :transactions => holding.transactions, holding_by_dollars: value})
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

  def create_managed_account(type, deposit, riskTolerance)
    account = Account.create(account_type: "Managed "+ riskTolerance + " " + type)
    account.account_number = account.generate_account_number
    money_market = Holding.create(name: "Money Marketfund", symbol: "MM", shares: deposit)
    money_market.transactions << Transaction.create(buy: true, execution_price: 1, shares_executed: deposit)
    account.holdings << money_market
    if riskTolerance === "Aggressive"
      aggressive = [0.36, 0.24, 0.28, 0.12]
      implementation_details = trade_details(deposit, aggressive)
    elsif riskTolerance === "Moderate"
      moderate = [0.30, 0.20, 0.35, 0.15]
      implementation_details = trade_details(deposit, moderate)
    elsif riskTolerance === "Conservative"
      conservative = [0.24, 0.16, 0.42, 0.18]
      implementation_details = trade_details(deposit, conservative)
    end
    implement_managed_portfolio(account, implementation_details)
    account.save
    self.accounts << account
    return self
  end

  def implement_managed_portfolio(account, implementation_details)
    implementation_details.each do |trade_data|
      trade_data.each do |symbol, trade_details|
          last_price = trade_details[:price]
          shares = trade_details[:shares]
          investment_name = account.get_holding_name(symbol)
          investment_to_be_transacted = Holding.create(name: investment_name, symbol: symbol)
          account.process_transaction("BUY", last_price, shares, investment_to_be_transacted)
      end
    end
  end

  def get_holding_prices
    @holding = Holding.new
    holdings = ["VTI", "VXUS", "BND", "BNDX"]
    holding_prices = []
    holdings.each do |holding|
      price = @holding.get_price(holding)
      holding_prices.push({holding => price})
    end
    return holding_prices
  end

  def trade_details(deposit, investment_percentages)
    holding_prices = get_holding_prices
    holding_prices_and_shares = []
    vti_percent = investment_percentages[0]
    vxus_percent = investment_percentages[1]
    bnd_percent = investment_percentages[2]
    bndx_percent = investment_percentages[3]
    holding_prices.each do |holding_data|
      holding_data.each do |key, value|
      if key == "VTI"
        shares = ((deposit.to_i * vti_percent)/value.to_f).floor
        holding_prices_and_shares.push({key => {:price => value, :shares => shares}})
      elsif key == "VXUS"
        shares = ((deposit.to_i * vxus_percent)/value.to_f).floor
        holding_prices_and_shares.push({key => {:price => value, :shares => shares}})
      elsif key == "BND"
        shares = ((deposit.to_i * bnd_percent)/value.to_f).floor
        holding_prices_and_shares.push({key => {:price => value, :shares => shares}})
      elsif key == "BNDX"
        shares = ((deposit.to_i * bndx_percent)/value.to_f).floor
        holding_prices_and_shares.push({key => {:price => value, :shares => shares}})
      end
     end
    end
    holding_prices_and_shares
  end

  def get_transactions
    transactions_by_account = {}
    self.accounts.each do |account|
      key = account.account_type + " " + account.account_number.to_s + "-" + account.id.to_s
      transactions_by_account[key] = []
    end
    self.accounts.each do |account|
      account.transactions.each do |transaction|
        key = account.account_type + " " + account.account_number.to_s + "-" + account.id.to_s
        type = "Buy"
        if transaction.buy === false
          type = "Sell"
        end
        transactions_by_account[key].push(
        {holding: transaction.holding.symbol,
         type: type,
         price: transaction.execution_price,
         date: transaction.created_at.strftime("%b %d. %Y"),
         shares: transaction.shares_executed})
      end
    end
    return transactions_by_account
  end
end
