# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe '#permitted_params' do
    let :subject do
      described_class.new.permitted_params
    end

    it { is_expected.to_not be_empty }
    it { is_expected.to all( be_a Symbol ) }
  end

  describe 'guest access' do
    before :each do 
      @user = guest
      @token = create_token(@user)
      request.headers['Authorization'] = @token
    end

    {
      index: :get,
      create: :post,
      update: :put,
      destroy: :delete,
      show: :get
    }.each do |action, verb|
      it "recieves 403 on #{action}" do
        send(verb, action, params: { id: 1 })
        expect(response).to have_http_status(403)
      end
    end
  end
end