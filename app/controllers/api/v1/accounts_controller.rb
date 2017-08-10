class Api::V1::AccountsController < ApplicationController

  def create
    @account = Account.new(account_type: account_params["type"])
    money_market = Holding.create(name: "Money Marketfund", symbol: "MM", shares: account_params["deposit"])
    money_market.transactions << Transaction.create(buy: true, execution_price: 1)
    @account.holdings << money_market
    current_user.accounts << @account
    render json: { user: current_user.username,
      account: @account,
      holdings: @account.holdings,
      transactions: @account.transactions }
  end


  def show
    @accounts = current_user.accounts
    #setting up empty data object to send back in the right format
    data = {:accounts => []}
    #iterating through and constructing the object here
    data.each do |key, value|
      @accounts.each do |account|
        value.push({:account => account, :holdings => []})
      end
    end

    #doing one more iteration and filling in the holdings and transactions
    data.each do |key, value|
      value.each do |object|
          @accounts.each do |account|
            if object[:account].id === account.id
              account.holdings.each do |holding|
                object.values[1].push({:holding => holding, :transactions => holding.transactions})
            end
          end
        end
      end
    end
    data[:username] = current_user.username
    render json: data
  end

  private

  def account_params
    params.permit(:bankname, :deposit, :type, :consent)
  end
end
