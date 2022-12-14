module Api::V1
  class ProductsController < ApplicationController
    before_action :authenticate_admin!, only: %i[create update destroy]

    def show
      render json: item.as_json(include: :prices)
    end

    def permitted_params
      %i[name description]
    end
  end
end