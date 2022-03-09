class LuckyFlow
  # = LuckyFlow Errors
  #
  # Generic LuckyFlow exception class.
  class Error < Exception
  end

  class NotSupportedByDriverError < Error
  end

  class NotSupportedByElementError < Error
  end

  class ElementNotFoundError < Error
    def initialize(driver : LuckyFlow::Driver, selector : String, inner_text : String?)
      message = LuckyFlow::ErrorMessageWhenNotFound.build(
        driver: driver,
        selector: selector,
        inner_text: inner_text
      )

      super message
    end
  end

  class DriverInstallationError < Error
    def initialize(error : Exception)
      message = <<-ERROR
      Something went wrong while installing the web driver

      If you'd like to manually install the web driver yourself, make sure to tell LuckyFlow where it is located:

        LuckyFlow.configure do |settings|
          settings.driver_path = "/path/to/webdriver"
        end
      ERROR

      super message, cause: error
    end
  end

  class InvalidOperationError < Error
  end

  class InvalidMultiSelectError < InvalidOperationError
    def initialize
      super "Unable to select multiple options when select element does not have 'multiple' attribute"
    end
  end

  class InfiniteRedirectError < Error
  end
end
