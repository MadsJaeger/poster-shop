# frozen_string_literal: true

##
# An order has a flow: starts with zero items, i.e. a basket order, items are then added.
# The user may then check ot the order which removes alle 0 amount items and updates prices
# on all items. Within 15 minutes the user may confirm the order and wgt the items at the 
# suggested prices. If delayed, the user must checkout again.
class Order < ApplicationRecord
  CONFIRMATION_INTERVAL = 15.minutes
  CONFIRM_MESSAGES = {
    no_checkout: 'The order has not been checked out. Please go to checkout before confirming the order',
    past_interval: 'Could not confirm the order as too long time has elapsed since checkout, please go to checkout again before confirming',
    zero_amount: 'Could not checkout as none of the card items has a positve amount.'
  }

  belongs_to :user, optional: false
  has_many   :items, dependent: :restrict_with_error, class_name: 'OrderItem'

  validates :checkout_at, absence: true, if: :empty?
  validates :confirmed_at, absence: true, if: :empty?
  validates :confirmed_at, absence: { message: CONFIRM_MESSAGES[:no_checkout] }, unless: :checkout_at
  validates :confirmed_at, comparison: {
    greater_than: :checkout_at,
    less_than: ->(this) {this.checkout_at + CONFIRMATION_INTERVAL},
    message: CONFIRM_MESSAGES[:past_interval]
  }, if: ->(this) { this.confirmed_at && this.checkout_at }
  validates :size, numericality: { greater_than: 0 }, if: ->(this) { this.checkout_at || this.confirmed_at }
  validates :amount, numericality: { greater_than: 0 }, if: ->(this) { this.checkout_at || this.confirmed_at }
  validates :user_id, uniqueness: { scope: :confirmed_at, message: 'Only one basket may exists per user' }, on: :create
  validates :user_id, static_attribute: true, on: :update
  # Assert no changes on items since confirmed af (destruction may be checked on value)

  before_save do
    update_prices unless confirmed? || checkout?
  end

  class << self
    def basket_for(user)
      basket.for(user).first || new(user: user)
    end

    def for(user)
      where(user: user)
    end

    def basket
      where(confirmed_at: nil)
    end
  end

  ##
  # Has this order been completed by the user
  def confirmed?
    !!confirmed_at
  end

  ##
  # Is the order under checkout, i.e. is the customer about to confirm
  def checkout?
    !!checkout_at
  end

  def size
    super || self.size = 0
  end

  def value
    super || self.value = 0.0
  end

  ##
  # Is the basket empty?
  def empty?
    items.empty?
  end

  def amount
    items.select { |item| !item.marked_for_destruction? }.map(&:amount).sum
  end

  def update_prices
    items.includes(:product).each(&:update_price).each(&:save)
  end

  ##
  # Getting an order statement and preparing order for confirmation, updating and locking prices for the
  # next 15 minutes. If users in the meantime deletes or adds items cahce_item_data will be called clearing
  # the checkout.
  def checkout
    items.where(amount: 0).destroy_all
    update_prices
    self.checkout_at = DateTime.now
    save
  end

  ##
  # Confirming order requires checkout, i.e. to get a total price of the order.
  def confirm
    self.confirmed_at = DateTime.now
    save
  end

  def item_data
    {
      size: items.count,
      value: items.sum(:value)
    }
  end

  def cache_item_data
    checkout = confirmed? ? checkout_at : nil
    update_columns(**item_data.merge({
      updated_at: DateTime.now,
      checkout_at: checkout
    }))
  end
end
