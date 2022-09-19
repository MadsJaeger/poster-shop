module Api::V1
  class OrderItemsController < ApplicationController
    before_action :authenticate_is_owner!
    before_action :authenticate_admin!, only: %i[create update destroy index]

    def permitted_params
      %i[user_id product_id amount order_id]
    end
  end
end