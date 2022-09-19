# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order,   optional: false
  belongs_to :user,    optional: false
  belongs_to :product, optional: false

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: %i[order_id] }, on: :create
  validates :price, numericality: { in: 0..999_999.99 }
  validates :product_id, :user_id, :order_id, static_attribute: true, on: :update
  # validates :amount, :price, static_attribute: true, on: :update, if: ->(this) { this.order.confirmed? }
  validates :user_id, numericality: { equal_to: ->(this) { this.order.user_id } }

  before_validation do
    self.user  ||= order.user if order
    self.order ||= Order.basket_for(user) if user
  end

  after_commit do
    order&.cache_item_data
  end

  def as_json(opts={})
    super(**{ include: %i[product], methods: %i[value] }.merge(opts))
  end

  def value
    (price || 0) * (amount || 0)
  end

  def update_price
    self.price = product&.price
  end

  def product=(other)
    super(other)
    update_price
  end

  def product_id=(value)
    super(value)
    update_price
  end
end