class BasketController < ApplicationController
  ##
  # Returns the current users basket
  def index
    order.items.each(&:update_price).each(&:save)
    render json: json_order
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
    order.items.destroy_all
    order.destroy!
  end

  private

  def order
    @order ||= Order.includes(items: :product).basket_for(@current_user)
  end

  def json_order
    @order.as_json(include: [items: { include: :product }])
  end

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
    @item ||= OrderItem.find_by(**item_identification) || OrderItem.new(product: product, user: @current_user)
  end

  def item_identification
    { product: product, user: @current_user, order: order }
  end

  def item_params
    { amount: amount }
  end
end