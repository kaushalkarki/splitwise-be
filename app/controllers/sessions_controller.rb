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

  def google
    token = params[:token]

    validator = GoogleIDToken::Validator.new
    begin
      payload = validator.check(token, ENV['GOOGLE_CLIENT_ID'])

      if payload
        user = User.find_or_create_by(email: payload['email']) do |u|
          u.name = payload['name']
          u.image_url = payload['picture']
        end

        jwt_token = JsonWebToken.encode(user_id: user.id)
        render json: { token: jwt_token, user: user }, status: :ok
      else
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    rescue GoogleIDToken::ValidationError => e
      render json: { error: "Cannot validate: #{e}" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

end
