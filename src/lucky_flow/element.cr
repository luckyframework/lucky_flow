class LuckyFlow::Element
  private getter raw_selector, session
  getter inner_text
  delegate text, click, send_keys, displayed?, attribute, to: element

  def initialize(@session : Selenium::Session, @raw_selector : String, text @inner_text : String? = nil)
  end

  @_element : Selenium::WebElement?

  private def element : Selenium::WebElement
    @_element ||= FindElement.run(session, selector, inner_text)
  end

  def value
    attribute("value")
  end

  def fill(value : String)
    send_keys value
  end

  def selector : String
    Selector.new(raw_selector).parse
  end
end
