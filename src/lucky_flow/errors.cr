class LuckyFlow
  # = LuckyFlow Errors
  #
  # Generic LuckyFlow exception class.
  class Error < Exception
  end

  class ElementNotFoundError < Error
    def initialize(selector : String, inner_text : String?, helper : String?)
      super LuckyFlow::ErrorMessageWhenNotFound.build(selector, inner_text,
                                                      helper)
    end
  end
end
