require "levenshtein"

# Find element on a page with a retry
class LuckyFlow::FindElement
  property tries : Int32 = 0
  private getter session, selector, inner_text

  def initialize(@session : Selenium::Session, @selector : String, text @inner_text : String? = nil)
  end

  def self.run(*args, **named_args)
    new(*args, **named_args).run
  end

  def run
    loop do
      matching_elements = find_matching_elements
      return matching_elements.first if matching_elements.first?

      break unless has_retries_left?
      sleep retry_delay_in_ms
    end

    raise_element_not_found_error
  end

  private def has_retries_left?
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

  private def find_matching_elements : Array(Selenium::Element)
    self.tries += 1
    session.find_elements(:css, selector).select do |element|
      text_to_check_for = inner_text
      if text_to_check_for
        element.text.includes?(text_to_check_for)
      else
        true
      end
    end
  rescue Selenium::Error
    [] of Selenium::Element
  end

  private def raise_element_not_found_error
    raise LuckyFlow::ElementNotFoundError.new(
      selector: selector,
      inner_text: inner_text
    )
  end
end
