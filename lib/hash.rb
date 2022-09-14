class Hash
  ##
  # Recursivly converts blank objects to nil. Returns self
  def nilify_blanks!
    transform_values! do |v|
      if v.is_a?(Hash)
        v.nilify_blanks!
      else
        v.blank? ? nil : v
      end
    end
  end

  ##
  # Recursively strips strings from leading and trailing whitespace. Returns self
  def strip_strings!
    transform_values! do |v|
      if v.is_a?(Hash)
        v.strip_strings!
      else
        v.is_a?(String) ? v.strip : v
      end
    end
  end
end