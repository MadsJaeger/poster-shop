# frozen_string_literal: true

##
# TODO:
# 1) Confirm email
# 2) Reset password token
# 3) Passeord changed at (security data)
# 4) Max token duration
#
class User < ApplicationRecord
  PASSWORD_REGX = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,45}\z/
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_REGEX }
  validates :password, format: { with: PASSWORD_REGX }, if: :password_digest_changed?
  validates :max_tokens, numericality: { min: 0, max: 12 }
end
