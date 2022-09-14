# frozen_string_literal: true

##
# TODO:
# 1) Confirm email
# 2) Implement lock and reset password
# 3) Passeord changed at (security data)
class User < ApplicationRecord
  PASSWORD_REGX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,45}\z/
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  has_secure_password :password, validations: false

  has_many :jtis, dependent: :destroy

  validates :email, uniqueness: true, format: { with: EMAIL_REGEX }, allow_blank: false
  with_options if: :password_digest_changed? do |user|
    user.validates :password, format: { with: PASSWORD_REGX }
    user.validates :password, confirmation: { case_sensitive: true }
    user.validates :password_confirmation, presence: true, allow_blank: false
  end
  validates :password_digest, presence: true, allow_blank: false
  validates :max_tokens, numericality: { min: 0, max: 12 }

  ##
  # Ensure emails always are downcased and stripped from leading and trailing spaces.
  def email=(value)
    super value.to_s.strip.downcase
  end
end