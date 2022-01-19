# Find element on a page with a retry
class LuckyFlow::FindElement
  private property tries : Int32 = 0
  private getter driver : LuckyFlow::Driver
  private getter selector : String
  private getter inner_text : String?

  def initialize(@driver, selector, text @inner_text = nil)
    @selector = Selector.new(selector).parse
  end

  def self.run(*args, **named_args) : LuckyFlow::Element
    new(*args, **named_args).run
  end

  def run : LuckyFlow::Element
    loop do
      matching_elements = find_matching_elements
      return matching_elements.first if matching_elements.first?

      break unless has_retries_left?
      sleep retry_delay_in_ms
    end

    raise_element_not_found_error
  end

  private def has_retries_left? : Bool
    tries < max_tries
  end

  private def max_tries : Int32
    (settings.stop_retrying_after / settings.retry_delay).to_i
  end

  private def retry_delay_in_ms : Float
    settings.retry_delay.total_milliseconds / 1_000
  end

  private def settings
    LuckyFlow.settings
  end

  private def find_matching_elements : Array(LuckyFlow::Element)
    self.tries += 1
    driver.find_css(selector).select do |element|
      text_to_check_for = inner_text
      if text_to_check_for
        element.text.includes?(text_to_check_for)
      else
        true
      end
    end
  end

  private def raise_element_not_found_error
    raise LuckyFlow::ElementNotFoundError.new(driver, selector, inner_text)
  end
end
