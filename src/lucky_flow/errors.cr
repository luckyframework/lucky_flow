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

  class DriverInstallationError < Error
    def initialize(error : Exception)
      message = <<-ERROR
      Something went wrong while installing Chromedriver:

        #{error}

      If you'd like to manually install Chromedriver yourself, make sure to tell LuckyFlow where it is located:

        LuckyFlow.configure do |settings|
          settings.chromedriver_path = "/path/to/chromedriver"
        end
      ERROR

      super message
    end
  end

  class InvalidOperationError < Error
  end

  class InvalidMultiSelectError < InvalidOperationError
    def initialize
      super "Unable to select multiple options when select element does not have 'multiple' attribute"
    end
  end
end
