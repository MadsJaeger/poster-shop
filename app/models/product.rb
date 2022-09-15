# frozen_string_literal: true

class Product < ApplicationRecord
  has_many  :prices, dependent: :restrict_with_error
  has_one   :price, -> { order(from: :desc) }
  has_many  :order_items, dependent: :restrict_with_error

  validates :name, presence: true, allow_blank: false

  def self.with_prices
    where(id: Price.select(:product_id).distinct)
  end

  def as_json(opts = {})
    super(**opts.deep_merge({ include: :price }))
  end
end