require 'rails_helper'

RSpec.describe '/users', type: :request do
  include AuthHelpers::RequestHelpers

  before :all do
    @uri   = 'users'
    @user  = admin
    @token = sign_in(@user)
  end

  describe 'GET, users' do
    before :each do
      @users = create_list(:user, 5)
      get
    end

    it 'it returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'it returns all users' do
      expect(body.size).to be User.count
    end

    it 'returns user as json' do
      expect(body).to eq User.all.as_json
    end
  end

  describe 'POST, creating a user' do
    describe 'Valid user' do
      before :each do
        @user = build(:user).slice(:email, :name, :password, :password_confirmation)
        post params: { user: @user }
      end

      it 'returns 200' do
        expect(response).to have_http_status(201)
      end

      it 'returns user as json' do
        user = User.find body['id']
        expect(body).to eq user.as_json
      end
    end

    describe 'invalid user' do
      it 'returns 400 on missing bag name' do
        post
        expect(response).to have_http_status(400)
      end

      it 'returns 422 on invalid item' do
        post params: { user: { email: 'Ups!' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '/users/:id' do
    before :each do
      @user = create(:user)
      @uri = "users/#{@user.id}"
    end

    describe 'GET, shows a user' do
      it 'returns 404 on bad :id' do
        get 'users/0'
        expect(response).to have_http_status(404)
      end

      it 'returns 200' do
        get
        expect(response).to have_http_status(200)
      end

      it 'returns as_json, with prices' do
        get
        expect(body).to eq @user.as_json
      end
    end

    describe 'PUT, updates a user' do
      it 'returns 422 with invalid data' do
        put params: { user: { email: nil } }
        expect(response).to have_http_status(422)
      end

      it 'returns 200 with valid data' do
        put params: { user: { email: 'new@mail.here' } }
        expect(response).to have_http_status(200)
      end
    end

    describe 'DELETE, destroys a user' do
      it 'returns 422 as orders are given' do
        create(:order, user: @user)
        delete
        expect(response).to have_http_status(422)
      end

      it 'returns 204, when no orders has been made' do
        delete
        expect(response).to have_http_status(204)
      end
    end
  end
end
