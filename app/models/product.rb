# frozen_string_literal: true

##
# Product has attribute price managed by the application. This breaks data-normality and duplicates
# the most recent price.value to the product instance. This is in order to avoid making a join or
# include statemnt on every display of a collection of products, as the price will always be of interest
class Product < ApplicationRecord
  has_many  :prices, dependent: :restrict_with_error
  has_many  :order_items, dependent: :restrict_with_error

  validates :name, presence: true, allow_blank: false

  ##
  # Takes the most recent prices and stores on self.
  # update_column(price, updated_at) could be used instead of save
  # skipping callbacks and increating performacne
  def update_price
    self.price = prices.select(:value).order(from: :desc).first&.value
    save
  end
end