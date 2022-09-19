module AuthHelpers
  PWD = 'Secure1' # MANUALLY ensure this match seed data, corresponding to admin and guest
  AGENT = 'Rails Testing'

  def admin
    @admin ||= User.where(admin: true).first
  end

  def guest
    @guest ||= User.where(admin: false).first
  end

  def sign_in(user, password: nil)
    post 'auth/sign_in',
      params: { user: { email: user.email, password: password || PWD } }
    @token = request['HTTP_AUTHORIZATION'] = response['Authorization']
  end

  def create_token(user)
    Authentication::JsonWebToken.create(user, OpenStruct.new(env: { 'HTTP_USER_AGENT' => AGENT }))
  end

  def body
    response.parsed_body
  end

  module RequestHelpers
    %i[get post put delete].each do |meth|
      define_method(meth) do |uri=nil, **kwargs|
        super("/api/v1/#{uri||@uri}", **request_headers.merge(kwargs) )
      end
    end

    def request_headers
      { headers: { 'Authorization' => @token, 'HTTP_USER_AGENT' => AGENT } }
    end
  end
end