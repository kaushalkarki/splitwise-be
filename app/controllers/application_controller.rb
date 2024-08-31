class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers['Authorization']
    if header.present?
      token = header.split(' ').last
      begin
        decoded = JsonWebToken.decode(token)
        if decoded
          @current_user = User.find(decoded[:user_id])
          if @current_user.nil?
            render json: { errors: 'User not found' }, status: :unauthorized
          end
        else
          render json: { errors: 'Invalid token or token has expired' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound
        render json: { errors: 'User not found' }, status: :unauthorized
      rescue JWT::DecodeError => e
        Rails.logger.info "JWT Decode Error: #{e.message}"
        render json: { errors: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { errors: 'Missing token' }, status: :unauthorized
    end
  end

end
  
