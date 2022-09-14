require 'rails_helper'

RSpec.describe Hash do
  describe 'nilify_blanks!' do
    let :example do
      {
        a: 1,
        b: '',
        c: {
          d: 1,
          e: '',
          f: {
            g: OpenStruct.new(blank?: true)
          }
        }
      }
    end

    let :expected do
      {
        a: 1,
        b: nil,
        c: {
          d: 1,
          e: nil,
          f: {
            g: nil
          }
        }
      }
    end

    it 'returns self' do
      expect(example.nilify_blanks!).to be(example)
    end

    it 'converts blank objects to nil' do
      expect(example.nilify_blanks!).to eq(expected)
    end

    it 'has no blank values' do
      example.define_singleton_method(:any_blank?) do
        any? { |k,v| k.is_a?(Hash) ? k.any_blank? : !v.nil? && v.blank? }
      end
      example.nilify_blanks!
      expect(example.any_blank?).to be false
    end
  end

  describe 'strip_strings' do
    let :example do
      {
        a: '  a  ',
        b: 'x',
        c: nil,
        d: OpenStruct.new,
        e: '  er  er',
        g: {
          h: {
            i: ' a'
          }
        }
      }
    end

    let :expected do
      {
        a: 'a',
        b: 'x',
        c: nil,
        d: OpenStruct.new,
        e: 'er  er',
        g: {
          h: {
            i: 'a'
          }
        }
      }
    end

    it 'returns self' do
      expect(example.strip_strings!).to be(example)
    end

    it 'strips leading and trailing whitespace deeply' do
      expect(example.strip_strings!).to eq(expected)
    end
  end
end