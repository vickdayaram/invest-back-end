class Account < ApplicationRecord
  has_many :holdings
  has_many :transactions, through: :holdings

  @@account_numbers = (1000000..2000000).to_a.shuffle

  def generate_account_number
    @@account_numbers.pop
  end

  def find_or_create_holding(investment)
    self.holdings.each do |holding|
      if holding.symbol === investment
        return holding
      end
    end
      return Holding.create(symbol: investment)
  end

  def process_transaction(transaction_type, last_price, shares, investment_to_be_transacted)
    if transaction_type === "BUY"
      self.process_buy(last_price, shares, investment_to_be_transacted)
    else
      self.process_sell(last_price, shares, investment_to_be_transacted)
    end
  end

  def process_buy(last_price, shares, investment_to_be_transacted)
      transaction_buy = (Transaction.create(buy: true, execution_price: last_price))
      amount = (shares.to_i * last_price.to_i)
      self.sell_money_market(amount)
      investment_to_be_transacted.transactions << transaction_buy
      investment_to_be_transacted.shares = investment_to_be_transacted.shares + shares.to_i
      self.holdings << investment_to_be_transacted
      self.save
  end

  def process_sell(last_price, shares, investment_to_be_transacted)
    transaction_sell = (Transaction.create(sell: true, execution_price: last_price))
    amount = (shares.to_i * last_price.to_i)
    self.buy_money_market(amount)
    investment_to_be_transacted.transactions << transaction_sell
    investment_to_be_transacted.shares = investment_to_be_transacted.shares - shares.to_i
    self.holdings << investment_to_be_transacted
    self.save
  end

  def sell_money_market(amount)
    money_market_sell = Transaction.create(sell: true, execution_price: 1)
    self.holdings.each do |holding|
      if holding.symbol === "MM"
        holding.transactions << money_market_sell
        holding.shares = holding.shares - amount
        holding.save
      end
    end
  end

  def buy_money_market(amount)
    money_market_buy = Transaction.create(buy: true, execution_price: 1)
    self.holdings.each do |holding|
      if holding.symbol === "MM"
        holding.transactions << money_market_buy
        holding.shares = holding.shares + amount
        holding.save
      end
    end
  end


end
