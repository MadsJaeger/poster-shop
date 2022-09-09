require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  
  before :each do
    subject.email = 'test@mail.here'
    subject.password = '1secureValidPwd' 
  end

  it 'subject is valid' do
    expect(subject).to be_valid
  end

  describe 'password' do
    it 'is encrypted' do
      expect(subject.password_digest).to_not eq subject.password
    end

    it 'is recognized' do
      expect(subject.password).to eq '1secureValidPwd'
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
          expect(subject).to be_valid
        end

      else

        it "#{pwd} is an invalid password" do
          subject.password = pwd
          expect(subject).to_not be_valid
          expect(subject.errors.size).to be 1
          error = subject.errors.find { |err| err.attribute == :password }
          type = pwd.nil? ? :blank : :invalid
          expect(error.type).to be type
        end

      end
    end

    it 'changing after create must also comply with regex' do
      subject.password = '1aA' * 2
      subject.save!
      subject.password = 'invalid'
      expect(subject).to_not be_valid
    end
  end

  describe 'max_tokens' do
    before :each do 
      subject.email = ''
    end

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

  describe 'email' do 
    it 'must look like an email' do
      subject.email = 'fool!'
      expect(subject).to_not be_valid
    end
  end
end
