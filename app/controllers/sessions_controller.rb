class SessionsController < ApplicationController
  skip_before_action :authorize_request, only: :create
  
  def create
    @user = User.find_by(email: user_params[:email])
      
    if @user&.authenticate(user_params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { data: { token: token, user: @user } }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    # Assuming you're using session-based authentication
    reset_session
    render json: { message: 'Logout successful' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

end
