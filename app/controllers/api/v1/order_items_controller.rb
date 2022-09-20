module Api::V1
  class OrderItemsController < ApplicationController
    before_action :authenticate_is_owner!, only: :show
    before_action :authenticate_admin!, only: %i[create update destroy]

    def index
      @data = if @current_user.admin
                OrderItem.all.eager_load(:product)
              else
                OrderItem.eager_load(:product).where(user: @current_user)
              end
      render json: @data
    end

    def permitted_params
      %i[user_id product_id amount order_id]
    end
  end
end