# frozen_string_literal: true

module Authentication
  ##
  # Password authentication strategy
  # TODO: implment lock on failed attempts to avoid brute force attacks
  class Password < Warden::Strategies::Base
    def valid?
      email && password
    end

    def email
      (params['user'] || {})['email']
    end

    def password
      (params['user'] || {})['password']
    end

    def authenticate!
      @current_user = User.find_by(email: email)
      return fail!('User not found') if @current_user.blank?
      return fail!('Invalid password') unless @current_user.authenticate(password)
      
      success!(@current_user)
    end
  end
end
