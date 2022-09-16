class BasketController < ApplicationController
  ##
  # Returns the current users basket
  def index
    @items = OrderItem.basket.where(user: @current_user).eager_load(:product).each(&:update_price).each(&:save)
    render json: @items
  end

  ##
  # :method: :update => Change the amount of an order item
  def update
    item.amount = amount
    update_amount
  end

  ##
  # Increment amount
  def buy
    item.amount += amount
    update_amount
  end

  def sell
    item.amount -= amount
    update_amount
  end

  ##
  # :method: :remove => Completely remove an order item
  alias remove destroy

  def checkout
  end

  def confirm
  end

  ##
  # Clear current users basket
  def destroy
    OrderItem.basket.where(user: @current_user).destroy_all
    # Maybe resolve response from wheter or not all records where succesfully destroyed
  end

  private

  ##
  # Ensures item has at least 0 amount and saves
  def update_amount
    item.amount = [item.amount, 0].max
    if item.save
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end
  
  def amount
    params.fetch(:amount, 1).to_i
  end

  def product
    @product ||= Product.find(params[:id])
  end

  def item
    @item ||= OrderItem.basket.find_by(**item_identification) || OrderItem.new(**item_identification)
  end

  def item_identification
    { product: product, user: @current_user }
  end

  def item_params
    { amount: amount }
  end
end