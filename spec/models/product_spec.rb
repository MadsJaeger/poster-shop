require 'rails_helper'

RSpec.describe Product, type: :model do
  let :subject do
    Product.new(
      name: 'Test',
      description: 'Lipsum'
    )
  end

  it 'subject is valid' do
    expect(subject).to be_valid
  end

  describe 'validations' do
    it 'requires a name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end
  end
end
