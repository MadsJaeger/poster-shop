module Api::V1
  class OrdersController < ApplicationController
    before_action :authenticate_admin!, only: %i[create update destroy]
    before_action :authenticate_is_owner!, only: :show

    def index
      @data = if @current_user.admin
                Order.all
              else
                Order.where(user: @current_user)
              end
      render json: @data
    end

    def show
      item.items.includes(:product)
      render json: item.as_json(include: [items: { include: :product }])
    end

    def permitted_params
      %i[user_id]
    end
  end
end