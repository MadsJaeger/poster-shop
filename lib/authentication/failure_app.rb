module Authentication
  ##
  # Authentication failure responds with 401
  class FailureApp < ActionController::API
    def index
      render json: { error: 'Unauthorized' }, status: 401
    end
  end
end
