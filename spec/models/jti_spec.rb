require 'rails_helper'

RSpec.describe Jti, type: :model do
  let :subject do
    build(:jti, user: admin)
  end

  describe 'validation' do
    it { is_expected.to be_valid }

    it 'requires a user' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors.map(&:attribute)).to eq [:user]
    end

    it 'requires a jti' do
      subject.jti = nil
      expect(subject).to_not be_valid
      expect(subject.errors.map(&:attribute)).to eq [:jti]
    end

    it 'required exp' do
      subject.exp = nil
      expect(subject).to_not be_valid
      expect(subject.errors.map(&:attribute)).to eq [:exp]
    end

    it 'requires an agent' do
      subject.agent = nil
      expect(subject).to_not be_valid
      expect(subject.errors.map(&:attribute)).to eq [:agent]
    end

    it 'agent may not be blank' do
      subject.agent = ''
      expect(subject).to_not be_valid
      expect(subject.errors.map(&:attribute)).to eq [:agent]
    end
  end

  it '#expired, returns expired records' do
    expect(described_class.expired.to_sql).to include 'WHERE (exp <'
  end

  it '#current, returns non-expired records' do
    expect(described_class.current.to_sql).to include 'WHERE (exp >'
  end

  describe '#signed_with' do
    before :each do
      subject.save
    end

    it 'returns nil on empty arguments' do
      expect(described_class.signed_with).to be_nil
    end

    it 'returns nil when jti is not given' do
      expect(described_class.signed_with(user_id: subject.user_id)).to be_nil
    end

    it 'returns nil when user_id not given' do
      expect(described_class.signed_with(jti: subject.jti)).to be_nil
    end

    it 'returns nil when user has not signed in with given jti' do
      expect(described_class.signed_with(jti: 'bad jti', user_id: subject.user_id)).to be_nil
    end

    it 'returns jti on match' do
      expect(described_class.signed_with(
        jti: subject.jti,
        user_id: subject.user_id
      )).to eq subject
    end
  end

  describe 'creation' do
    before :each do
      admin.max_tokens = 2
      @jtis = create_list(:jti, 2, user: admin)
    end

    it 'deletes elder tokens' do
      stamps = @jtis.map(&:updated_at)
      stamps << create(:jti, user: admin).updated_at
      expect(Jti.where(user: admin).pluck(:updated_at)).to eq stamps[1..]
    end

    it 'keeps max_tokens' do
      create(:jti, user: admin)
      expect(Jti.where(user: admin).count).to be 2
    end
  end
end
