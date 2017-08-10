require 'rest_client'
require 'json'

class Api::V1::TransactionsController < ApplicationController

  @@apiKey = "NKIEQH9ZHQ1ZFJVL"

  def create
    #we find the account number, and then locate the account
    account_number = transaction_params["account"].split(" ")[3]
    @account = current_user.accounts.find_by(account_number: account_number)

    #parse out the request further
    investment = transaction_params["investment"]
    transaction_type = transaction_params["transaction"]
    amount = transaction_params["amount"]

    #make api call
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{investment}&interval=15min&outputsize=full&apikey=NKIEQH9ZHQ1ZFJVL"
    response = RestClient.get(url)
    json = JSON.parse(response)

    #determine our execution price for now
    last_price = json["Time Series (15min)"].first[1]["1. open"]

    #check to see if the holding symbols already exist in our account
    investment_to_be_transacted = []
    @account.holdings.each do |holding|
      if holding.symbol === investment
        investment_to_be_transacted.push(holding)
      end
    end

    # if no investment was found then we create a new investment
    if investment_to_be_transacted.length === 0
      investment_to_be_transacted.push(Holding.create(symbol: investment))
    end

    # if the transaction is equal to buy, we create a new transaction accordingly
    # also we adjust the accounts money market fund balance
    transaction = []
    if transaction_type === "BUY"
      transaction.push(Transaction.create(buy: true, execution_price: last_price))
      money_market_sell = Transaction.create(sell: true, execution_price: 1)
      @account.holdings[0].transactions << money_market_sell
      @account.holdings[0].shares = @account.holdings[0].shares - amount.to_i
      @account.holdings[0].save
      investment_to_be_transacted[0].transactions << transaction[0]
      investment_to_be_transacted[0].shares = investment_to_be_transacted[0].shares + (amount.to_i/last_price.to_i)
      @account.holdings << investment_to_be_transacted[0]
      @account.save
    else
      transaction.push(Transaction.create(sell: true, execution_price: last_price))
      money_market_buy = Transaction.create(buy: true, execution_price: 1)
      @account.holdings[0].transactions << money_market_buy
      @account.holdings[0].shares = @account.holdings[0].shares + amount.to_i
      @account.holdings[0].save
      investment_to_be_transacted[0].transactions << transaction[0]
      investment_to_be_transacted[0].shares = investment_to_be_transacted[0].shares - (amount.to_i/last_price.to_i)
      @account.holdings << investment_to_be_transacted[0]
      @account.save
    end
    
    render json: @account.holdings
  end

  private

  def transaction_params
    params.permit(:account, :transaction, :investment, :amount)
  end
end
