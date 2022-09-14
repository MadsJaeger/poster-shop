require 'rails_helper'

RSpec.describe Order, type: :model do
  before :all do
    @user = User.create!(
      name:                  'Tester',
      email:                 'test@email.here',
      password:              '!1SecurePwd',
      password_confirmation: '!1SecurePwd',
    )
  end

  let :subject do
    describe_class.new(
      user: @user
    )
  end

  describe 'validations' do
    it 'subject is valid' do
      expect(subject).to be_valid
    end
  end

  after :all do
    @user.destroy!
  end
end
