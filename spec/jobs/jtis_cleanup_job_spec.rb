require 'rails_helper'

RSpec.describe JtiCleanupJob, type: :job do
  describe '#perform' do
    before :each do
      @user = create(:user)
      create(:jti, user: @user, exp: DateTime.now + 5.seconds)
      build(:jti, user: @user, exp: DateTime.now - 5.seconds).save(validate: false)
      subject.perform
    end

    it 'persist current jtis' do
      expect(Jti.where(user: @user).count).to be 1
    end

    it 'deletes expired jtis' do
      expect(Jti.where(user: @user).expired.count).to be 0
    end
  end
end