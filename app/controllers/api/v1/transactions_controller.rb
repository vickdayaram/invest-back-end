class Api::V1::TransactionsController < ApplicationController

  def create
    #break down request
    account_id = transaction_params["account_id"]
    investment = transaction_params["investment"]
    transaction_type = transaction_params["transaction"]
    shares = transaction_params["shares"]
    #locate account
    @user = current_user
    @account = @user.accounts.find_by(id: account_id)
    #retrieve price for appropriate investment
    @holding = Holding.new
    execution_price = @holding.get_price(investment)

    #locate the investment within the account or add it to the account
    investment_to_be_transacted = @account.find_or_create_holding(investment)

    #process the transaction
    @account.process_transaction(transaction_type, execution_price, shares, investment_to_be_transacted)

    render json: @account.holdings
  end

  def show
    @user = current_user
    @transactions = @user.get_transactions
    render json: @transactions
  end

  private

  def transaction_params
    params.permit(:transaction, :investment, :shares, :account_id)
  end
end
