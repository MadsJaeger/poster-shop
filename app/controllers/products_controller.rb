class ProductsController < ApplicationController
  before_action :authenticate_admin!, only: %i[create update destroy]

  def permitted_params
    %i(name description)
  end
end
