# frozen_string_literal: true

module Api::V1
  class AuthenticationController < ActionController::API
    USER_PARAMS = %i[name email password password_confirmation max_tokens token_duration].freeze

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end

    ##
    # TODO: Ensure not to tell users once email is taken
    def sign_up
      @user = User.new(**params.require(:user).permit(*USER_PARAMS))

      if @user.save
        authenticate!
        render json: @user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def sign_in
      params.require(:user).require([:email, :password])
      @user = warden.authenticate!(:pwd)
      authenticate!
      render json: @user
    end

    ##
    # Use parameter :all => true to remove all issued tokens.
    def sign_out
      begin
        @decoded, @jti = Authentication::JsonWebToken.decode(token)
        if (params[:all] == true) || (params[:all] == 'true')
          @user = User.find @decoded['user']['id']
          @user.jtis.delete_all
        else
          @jti.destroy
        end
        render json: { message: 'JTI deleted' }, status: 200
      rescue *Authentication::JsonWebToken::DECODE_EXCEPTIONS
        render json: { message: 'JWT not identified or expired' }, status: 204
      end
    end

    ##
    # Check wheter or not a user has a valid Authorization header with the JWT strategy
    def ping
      @user, @decoded, @jti = warden.authenticate!(:jwt)
      data = @decoded.except('user')
      data[:user] = @user
      data['message'] = 'Pong!'

      render json: data
    end

    private

    def authenticate!
      response.headers['Authorization'] = Authentication::JsonWebToken.create(@user, request)
    end

    def warden
      request.env['warden']
    end

    def token
      request.headers['Authorization']
    end
  end
end