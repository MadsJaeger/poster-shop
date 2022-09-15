##
# TODO: Implement a locking mechanism => dont allow prices to be changed nor destroyed once purchases has been made
# on the given price (currently only admins has access, theese oughta be wise enough to rrespect data)
class Price < ApplicationRecord
  MIN_FROM = Date.parse('2000-01-01 00:00:00 UTC')

  belongs_to :product, optional: false
  has_many   :order_items, dependent: :restrict_with_error

  validates :from, presence: true, comparison: { greater_than: MIN_FROM, less_than: ->(_x){ DateTime.now } }
  validates :from, uniqueness: { scope: :product_id }, on: :create
  validates :value, numericality: { in: 0..999_999.99 }
end
