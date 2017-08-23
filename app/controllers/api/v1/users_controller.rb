class Api::V1::UsersController < ApplicationController

  def index
    @users = User.all
    render json: @users
  end

  def create
    @user = User.new(user_params)
    @user.create_account("Individual", 10000)
    if !!@user.save
      @user.save
      created_jwt = issue_token({id: @user.id})
      render json: {username: @user.username, jwt: created_jwt}
    else
      render json: {errors: @user.errors.full_messages}
    end
  end

  def show
    @user = current_user
    render json: @user.portfolio_total_and_allocation
  end

  private

  def user_params
    params.permit(:username, :password)
  end

end
