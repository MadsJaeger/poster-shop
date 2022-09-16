class OrderItemsController < ApplicationController
  before_action :authenticate_is_owner!
  before_action :authenticate_admin!, only: %i[create update destroy index]
  
  def index
    OrderItem.eager_load(:product)
  end

  def permitted_params
    %i[user_id product_id amount order_id]
  end
end
