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

  private

  def account_params
    params.permit(:bankname, :deposit, :type, :consent)
  end
end
