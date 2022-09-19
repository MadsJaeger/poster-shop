
module Api::V1
  class PricesController < ApplicationController
    before_action :authenticate_admin!, only: %i[create update destroy]

    def permitted_params
      %i[product_id from value]
    end
  end
end