class Api::V1::AccountsController < ApplicationController

  def create
    type = account_params["type"]
    deposit = account_params["deposit"]
    risk_tolerance = account_params["riskTolerance"]
    @user = current_user
    if risk_tolerance.length > 0
    new_account = @user.create_managed_account(type, deposit, risk_tolerance)
    else
    new_account = @user.create_account(type, deposit)
    end 
    render json: new_account
  end


  def show
    @user = current_user
    data = @user.format_json
    render json: data
  end

  private

  def account_params
    params.permit(:bankname, :deposit, :type, :consent, :riskTolerance)
  end
end
