class Api::V1::TransactionsController < ApplicationController

  def create
    #break down request
    account_number = transaction_params["account"].split(" ")[3]
    investment = transaction_params["investment"]
    transaction_type = transaction_params["transaction"]
    amount = transaction_params["amount"]

    #locate account
    @user = current_user 
    @account = @user.accounts.find_by(account_number: account_number)

    #retrieve price for appropriate investment
    @holding = Holding.new
    execution_price = @holding.get_price(investment)

    #locate the investment within the account or add it to the account
    investment_to_be_transacted = @account.find_or_create_holding(investment)

    #process the transaction
    @account.process_transaction(transaction_type, execution_price, amount, investment_to_be_transacted)

    render json: @account.holdings
  end

  private

  def transaction_params
    params.permit(:account, :transaction, :investment, :amount)
  end
end
