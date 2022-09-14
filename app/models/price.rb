class Price < ApplicationRecord
  MIN_FROM = Date.parse('2000-01-01 00:00:00 UTC')

  belongs_to :product, optional: false
  validates :from, presence: true, comparison: { greater_than: MIN_FROM, less_than: ->(_x){ DateTime.now } }
  validates :from, uniqueness: { scope: :product_id }, on: :create
  validates :value, numericality: { in: 0..999_999.99 }
end
