module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_admin!

    def permitted_params
      %i[name email admin password password_confirmation locked_at max_tokens token_duration]
    end
  end
end