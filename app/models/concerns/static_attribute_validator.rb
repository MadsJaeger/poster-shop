# frozen_string_literal: true

##
# Validates that an attribute cannot change since last save
#
#   validates :foreign_key, static_attribute: true, on: :update
# 
# Must respond to #{attribute}_changed? on the used attributes
class StaticAttributeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    record.errors.add attribute, :static_attribute, **{ message: 'may not change'}.merge(options) if record.send("#{attribute}_changed?")
  end
end
