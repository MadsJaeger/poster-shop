module Api::V1
  class ApplicationController < ActionController::API
    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: 404
    end

    rescue_from ActiveModel::RangeError do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    before_action :authenticate!

    ## CRUD ACTIONS ##

    def index
      @items = self.class.model.all
      render json: @items
    end

    def show
      render json: item
    end

    def create
      @item = self.class.model.new(item_params)
      if @item.save
        render json: @item, status: :created, location: @item
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end

    def update
      if item.update(item_params)
        render json: @item
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end

    def destroy
      if item.destroy
        render json: nil, status: :no_content
      else
        render json: @item.errors, status: :unprocessable_entity
      end
    end

    ## HELPERS ##

    ##
    # Record of interest given params[:id] and infered from controller name
    def item
      @item ||= set_item
    end

    def set_item
      @item = self.class.model.find(params[:id])
    end

    ##
    # Converint clas name to parameter bag name: ProducstControelr => :product
    def self.model_name
      name.demodulize[0..-11].underscore.singularize.to_sym
    end

    ##
    # The related model: ProductsControler => Product
    def self.model
      model_name.to_s.camelize.constantize
    end

    ##
    # Returns a Hash of permitted parameters for the item, requiring the item as a paramter
    def item_params
      sanitize_params(params.require(self.class.model_name), permitted_params)
    end

    ##
    # Parameters to permit on item
    def permitted_params
      []
    end

    ##
    # Converts parameters to a Hash with deep symbols, blanks converted to nil, and strings trimmed from
    # leading and trailing space
    def sanitize_params(parameters, keys)
      parameters.permit(*keys).to_h.strip_strings!.nilify_blanks!.deep_symbolize_keys
    end

    private
    def forbidden!
      render json: { errors: 'Forbidden!' }, status: 403
    end

    def authenticate!
      @current_user, _decoded, _jti = request.env['warden'].authenticate!(:jwt)
    end

    def authenticate_admin!
      forbidden! unless @current_user.admin
    end

    def authenticate_is_owner!
      return true if @current_user.admin
      
      forbidden! unless item.user_id.to_i == @current_user.id
    end
  end
end