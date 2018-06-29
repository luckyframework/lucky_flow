class LuckyFlow
  class ErrorMessageWhenNotFound
    def self.build(selector : String, inner_text : String?, helper : String? =
                   nil, negate : Bool = false)
      String.build do |message|
        message << "Expected "
        message << "not " if negate
        message << "to find element on page, but it was "
        message << "not " unless negate
        message << "found."
        message << "\n\n  ▸ looking for: #{selector}"
        if helper
          message << "\n\n"
          message << " Did you mean..."
          message << "\n\n  ▸ "
          message << "'@#{helper}'\n"
        end
        unless (inner_text || "").empty?
          message << "\n  ▸ with text: #{inner_text}"
        end
      end
    end
  end
end
