require 'rails_helper'

RSpec.describe Product, type: :model do
  let :subject do
    Product.new(
      name: 'Test',
      description: 'Lipsum'
    )
  end

  describe 'validations' do
    it 'subject is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'cannot destroy when prices are given' do
      subject.prices.build(value: rand, from: DateTime.now - 1.day)
      subject.save!
      expect(subject.destroy).to be false
      expect(subject.errors.size).to be 1
    end
  end
end
