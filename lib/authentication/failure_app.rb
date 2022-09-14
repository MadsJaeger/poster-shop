module Authentication
  ##
  # Authentication failure responds with 401
  class FailureApp < ActionController::API
    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def index
      respond
    end

    def respond
      render json: { error: 'Unauthorized' }, status: 401
    end
  end
end
