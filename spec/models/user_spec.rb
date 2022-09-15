require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  
  let :subject do
    build(:user)
  end

  it 'subject is valid' do
    expect(subject).to be_valid
  end

  it 'cant destroy when having orders' do
    subject.save!
    subject.orders.build
    expect(subject.destroy).to be false
  end

  it 'cant destroy when having order_items' do
    subject.save!
    subject.order_items.build
    expect(subject.destroy).to be false
  end

  it 'converts to json' do
    expect(subject.as_json).to be_instance_of Hash
  end

  describe 'password' do
    it 'is encrypted' do
      expect(subject.password_digest).to_not eq subject.password
    end

    it 'is recognized' do
      expect(subject.password).to eq '!Secure1'
    end

    it 'authenticates' do
      expect(subject.authenticate('!Secure1')).to be subject
    end

    it 'must be confirmed' do
      subject.password_confirmation = nil
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 1
    end

    it 'must be confirmed and same' do
      subject.password_confirmation = 'flunk'
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 1
    end

    {
      'test'            => false,
       '1'              => false,
       nil              => false,
       '23424234234'    => false,
       'AAAAAAAAAAA'    => false,
       'eeweeeeeqw1$21' => false,
       'A1a'*15 + 'c'   => false,
       'EA1'            => false,
       '23erAA'         => true,
       'A1a'*15         => true,
    }.each do |pwd, valid|
      if valid

        it "#{pwd} is valid password" do
          subject.password = pwd
          subject.password_confirmation = pwd
          expect(subject).to be_valid
        end

      else

        it "#{pwd} is an invalid password" do
          subject.password = pwd
          subject.password_confirmation = pwd
          expect(subject).to_not be_valid
          expect(subject.errors.size).to be 1
          error = subject.errors.first
          type = pwd.nil? ? :blank : :invalid
          expect(error.type).to be type
        end

      end
    end

    it 'changing after create must also comply with regex' do
      subject.save!
      subject.password = 'invalid'
      subject.password_confirmation = 'invalid'
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 1
    end
  end

  describe 'max_tokens' do
    it 'has defaulted value 5' do
      expect(subject.max_tokens).to be 5
    end

    it 'must not be negative' do
      subject.max_tokens = -1
      expect(subject).to_not be_valid
    end

    it 'must be less than 13' do
      subject.max_tokens = 13
      expect(subject).to_not be_valid
    end
  end

  describe 'token_duration' do
    it 'must not be negative less tahn 15' do
      subject.token_duration = 14
      expect(subject).to_not be_valid
    end

    it 'must be more than 90 days' do
      subject.token_duration = 7_776_001
      expect(subject).to_not be_valid
    end
  end

  describe 'email' do 
    it 'must be given' do
      subject.email = nil
      expect(subject).to_not be_valid
    end

    it 'must not be blank given' do
      subject.email = ''
      expect(subject).to_not be_valid
    end

    it 'must look like an email' do
      subject.email = 'fool!'
      expect(subject).to_not be_valid
    end

    it 'dwoncases' do
      subject.email = 'EMAIL'
      expect(subject.email).to eq 'email'
    end

    it 'strips leading and trailing whitespace' do
      subject.email = " space  \n"
      expect(subject.email).to eq 'space'
    end
  end
end
