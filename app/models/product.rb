# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :prices, dependent: :restrict_with_error
  validates :name, presence: true, allow_blank: false
end
