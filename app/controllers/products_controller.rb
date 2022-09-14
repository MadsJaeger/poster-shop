class ProductsController < ApplicationController
  before_action :authenticate_admin!, only: %i[create update destroy]

  # Determine wheter or not products wihtout prices should be returned!
  def index
    render json: Product.eager_load(:price)
  end

  def permitted_params
    %i[name description]
  end
end
