class Product < ApplicationRecord
  validates :name, presence: true, allow_blank: false
end
