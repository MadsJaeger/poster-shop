# frozen_string_literal: true

##
# Json Web Token ID's
# TODO:
#  1) Make Cleanup job and schedle weekly
#  2) Add ip column to track from where users login 
class Jti < ApplicationRecord
  self.primary_key = :jti
  belongs_to :user, optional: false
  validates :agent, :jti, presence: true, allow_blank: false
  validates :exp, comparison: { greater_than: ->(_){ DateTime.now } }, allow_blank: false

  after_create do
    delete_elder_siblings!
  end

  def self.expired
    where('exp < ?', Time.zone.now)
  end

  def self.current
    where('exp > ?', Time.zone.now)
  end

  ##
  # Finds a Jti whn both jti index and user_id given, i.e. signed tokens
  # for a given user.
  def self.signed_with(jti: nil, user_id: nil)
    return nil unless jti && user_id

    current.find_by(user_id: user_id, jti: jti)
  end

  ##
  # After creation ensure that old issued tokens are deleted to avoid too many open
  # tokens at once.
  def delete_elder_siblings!
    self.class.where(user_id: user.id).order(updated_at: :desc).offset(user.max_tokens).delete_all if user
  end
end
