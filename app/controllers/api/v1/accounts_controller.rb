class Api::V1::AccountsController < ApplicationController

  def create
    type = account_params["type"]
    deposit = account_params["deposit"]
    @user = current_user
    new_account = @user.create_account(type, deposit)
    render json: new_account
  end


  def show
    @user = current_user
    data = @user.format_json
    render json: data
  end

  private

  def account_params
    params.permit(:bankname, :deposit, :type, :consent)
  end
end
