module Api::V1
  class OrdersController < ApplicationController
    before_action :authenticate_admin!, only: %i[create update destroy index]
    before_action :authenticate_is_owner!

    def permitted_params
      %i[user_id]
    end
  end
end