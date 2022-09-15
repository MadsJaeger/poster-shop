# frozen_string_literal: true

##
# Registration of checked out order items per user
class Order < ApplicationRecord
  belongs_to :user, optional: false
  has_many :order_items, dependent: :restrict_with_error

  before_validation do
    associate_order_items
  end

  validates :order_items, length: { minimum: 1 }

  def associate_order_items
    self.order_items += OrderItem.basket.where(user: user)
  end
end
