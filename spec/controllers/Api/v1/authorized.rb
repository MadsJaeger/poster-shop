def make_token(user)
  @token = Authentication::JsonWebToken.create(user, OpenStruct.new(env: { 'HTTP_USER_AGENT' => 'Rails Testing' }))
end

RSpec.configure do |config|
  config.before(:all, type: :controller) do
    @user = create(:user, admin: true)
    make_token(@user)
  end

  config.before(:each, type: :controller) do
    request.headers['Authorization'] = @token
  end

  config.after(:all, type: :controller) do
    @user.destroy!
  end
end
