# frozen_string_literal: true

class Product < ApplicationRecord
  has_many  :prices, dependent: :restrict_with_error
  has_one   :price, -> { order(from: :desc) }
  validates :name, presence: true, allow_blank: false

  def self.with_prices
    where(id: Price.select(:product_id).distinct)
  end
end