# frozen_string_literal: true

##
# OrderItem encapsulates two concepts, a shopping basket and a complete order. When users adds order-items 
# without an order they hav added items into their basket. By checking out an order instance will be created
# and the entire basket will be associated to the order, leaving the basket empty and the order complete
# with a group of items
class OrderItem < ApplicationRecord
  belongs_to :order,   optional: true
  belongs_to :user,    optional: false
  belongs_to :product, optional: false
  belongs_to :price,   optional: false # Unpriced products cannot be purchased

  validates :amount, numericality: { greater_than: 0 }, if: :order
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: %i[order_id user_id] }, on: :create
  validates :product_id, uniqueness: { scope: %i[order_id user_id] }, if: :order_id_changed?
  # STATIC ATTRIBUTES: product_id, user_id, order_id, { price => if order_id}

  def self.basket
    where(order_id: nil)
  end

  def update_price
    self.price = product&.price
  end

  def product=(other)
    super(other)
    update_price
    self.price = nil unless product
  end
end