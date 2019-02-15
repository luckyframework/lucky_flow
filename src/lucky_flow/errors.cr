class LuckyFlow
  # = LuckyFlow Errors
  #
  # Generic LuckyFlow exception class.
  class Error < Exception
  end

  class ElementNotFoundError < Error
    def initialize(selector : String, inner_text : String?)
      message = LuckyFlow::ErrorMessageWhenNotFound.build(
        selector: selector,
        inner_text: inner_text
      )

      super message
    end
  end
end
