class Account < ApplicationRecord
  has_many :holdings
  has_many :transactions, through: :holdings

  @@account_numbers = (1000000..2000000).to_a.shuffle

  def generate_account_number
    @@account_numbers.pop
  end

  def get_holding_name(symbol)
    name = ""
    if symbol === "VTI"
      name = "Vanguard Total Stock Market ETF"
    elsif symbol === "VXUS"
      name = "Vanguard Total International Stock Market ETF"
    elsif symbol === "BND"
      name = "Vanguard Total Bond Market ETF"
    elsif symbol === "BNDX"
      name = "Vanguard Total International Bond Market ETF"
    end
    name
  end

  def find_or_create_holding(investment, name)
    self.holdings.each do |holding|
      if holding.symbol === investment
        return holding
      end
    end
      return Holding.create(symbol: investment, name: name)
  end

  def process_transaction(transaction_type, last_price, shares, investment_to_be_transacted)
    if transaction_type === "BUY"
      self.process_buy(last_price, shares, investment_to_be_transacted)
    else
      self.process_sell(last_price, shares, investment_to_be_transacted)
    end
  end

  def process_buy(last_price, shares, investment_to_be_transacted)
    transaction_buy = (Transaction.create(buy: true, execution_price: last_price.to_f.round(2), shares_executed: shares))
    amount = (shares.to_i * last_price.to_f).to_f.round(2)
    self.sell_money_market(amount)
    investment_to_be_transacted.transactions << transaction_buy
    investment_to_be_transacted.shares = investment_to_be_transacted.shares + shares.to_i
    self.holdings << investment_to_be_transacted
    self.save
  end

  def process_sell(last_price, shares, investment_to_be_transacted)
    transaction_sell = (Transaction.create(sell: true, execution_price: last_price.to_f.round(2), shares_executed: shares))
    amount = (shares.to_i * last_price.to_f).to_f.round(2)
    self.buy_money_market(amount)
    investment_to_be_transacted.transactions << transaction_sell
    investment_to_be_transacted.shares = investment_to_be_transacted.shares - shares.to_i
    self.holdings << investment_to_be_transacted
    self.save
  end

  def sell_money_market(amount)
    money_market_sell = Transaction.create(sell: true, execution_price: 1, shares_executed: amount)
    self.holdings.each do |holding|
      if holding.symbol === "MM"
        holding.transactions << money_market_sell
        holding.shares = holding.shares - amount
        holding.save
      end
    end
  end

  def buy_money_market(amount)
    money_market_buy = Transaction.create(buy: true, execution_price: 1, shares_executed: amount)
    self.holdings.each do |holding|
      if holding.symbol === "MM"
        holding.transactions << money_market_buy
        holding.shares = holding.shares + amount
        holding.save
      end
    end
  end


end
