require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  def sign_in
    @response = post :sign_in, params: { user: { email: @user[:email], password: @user[:password] } }
    @token = @response['Authorization']
    @decoded  = JWT.decode(@token, nil, false)
    request.headers['Authorization'] = @token
  end

  before :all do 
    @user = {
      name: 'Nick Man',
      email: 'test@mail.here',
      password: '1validPwd',
      password_confirmation: '1validPwd',
      token_duration: 1800,
      max_tokens: 3
    }
  end

  describe 'POST #sign_up' do
    describe 'with valid data' do
      before :each do
        @response = post :sign_up, params: { user: @user }
        @decoded  = JWT.decode(@response['Authorization'], nil, false)
      end

      it 'creates a user' do
        @user = User.last
        list  = %i[name email token_duration max_tokens]
        expect(@user.values_at(*list)).to eq(@user.values_at(*list))
      end

      it 'sets jwt in response header' do
        expect(@decoded[0]['user']['name']).to eq @user[:name]
      end

      it 'stores a JTI' do
        jti        = @decoded[0]['jti']
        jti_record = Jti.find(jti)
        expect(jti_record.persisted?).to be true
      end

      it 'renders the user' do
        user = @response.parsed_body.symbolize_keys
        expect(user[:name]).to eq(@user[:name])
      end
    end

    describe 'with invalid data' do
      it 'without :user renders 400' do
        expect(post(:sign_up).status).to be 400
      end

      it 'with invalid users renders 422' do
        expect(post(:sign_up, params: { user: { name: 'Garfunkel' } }).status).to be 422
      end

      it 'with taken email does not disclose it' do
        post :sign_up, params: { user: @user }
        res = post :sign_up, params: { user: @user }
        expect(res.parsed_body.keys).to_not include('email')
      end
    end
  end

  describe 'POST #sign_in' do
    before :each do
      @user_record = User.create(**@user)
    end

    {
      'throws 400 on missing user' => [
        nil, 400
      ],
      'throws 400 on missing password' => [
        { user: { email: 'missing' } }, 400
      ],
      'throws 400 on missing email' => [
        { user: { password: 'missing' } }, 400
      ],
      'throws 401 on bad email apssword combination' => [
        { user: { email: 'folly', password: 'missing' } }, 401
      ],
      'throws 401 on bad password password combination' => [
        { user: { email: 'test@mail.here', password: 'wrong' } }, 401
      ],
    }.each do |mesg, data| 
      it mesg do
        expect( post(:sign_in, params: data[0]).status ).to be data[1]
      end
    end

    describe 'with correct credentials' do
      before :each do
        sign_in
      end

      it 'returns 200' do
        expect(@response.status).to be 200
      end

      it 'sets authorization in header' do
        expect(@response['Authorization']).to be_a String
      end

      it 'issues a JTI' do
        jti        = @decoded[0]['jti']
        jti_record = Jti.find(jti)
        expect(jti_record.persisted?).to be true
      end

      it 'has user in body' do
        user = @response.parsed_body.symbolize_keys
        expect(user[:name]).to eq(@user[:name])
      end

      it 'signing in more than max_tokens deletes old tokens' do
        @user[:max_tokens].times do
          sign_in
        end
        expect(@user_record.jtis.count).to eq @user[:max_tokens]
      end
    end
  end

  describe 'DELETE #sign_out' do
    before :each do
      @user_record = User.create(**@user)
      sign_in
    end

    it 'returns 204 on invalid auth' do
      request.headers['Authorization'] = nil
      expect(delete(:sign_out).status).to be 204
    end

    it 'deletes current token' do
      res = delete(:sign_out)
      expect(res.status).to be 200
      expect(Jti.where(user_id: @user_record.id).count).to be 0
    end

    it 'delete all tokens with :all' do
      sign_in
      expect(Jti.where(user_id: @user_record.id).count).to be 2
      delete(:sign_out, params: { all: true })
      expect(Jti.where(user_id: @user_record.id).count).to be 0
    end
  end

  describe 'GET #ping' do
    before :each do
      @user_record = User.create(**@user)
      @token = Authentication::JsonWebToken.create(@user_record, request)
      request.headers['Authorization'] = @token
      @ping = get(:ping)
    end

    it 'returns 401 without Authorization' do
      request.headers['Authorization'] = 'shitty token'
      expect( get(:ping).status ).to eq 200
    end

    it 'returns 200' do
      expect(@ping.status).to be 200
    end

    it 'returns exp' do
      expect(@ping.parsed_body.keys).to include('exp')
    end

    it 'returns user' do
      expect(@ping.parsed_body.keys).to include('user')
    end

    it 'pongs' do
      expect(@ping.parsed_body['message']).to eq 'Pong!'
    end
  end
end
