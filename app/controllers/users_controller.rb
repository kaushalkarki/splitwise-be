class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      render json: {user: @user}, status: :ok
    else
      render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      render json: { user: @user }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :phone, :password)
  end
end
