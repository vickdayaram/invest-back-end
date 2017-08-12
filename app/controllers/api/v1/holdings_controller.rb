class Api::V1::HoldingsController < ApplicationController

  def show
    @user = current_user
    @holdings = @user.holdings
    render json: @holdings
  end

end
