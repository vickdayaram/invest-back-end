class Api::V1::HoldingsController < ApplicationController

  def show
    @holdings = current_user.holdings
    render json: @holdings
  end 
end
