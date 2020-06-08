class LuckyFlow::Element
  private getter raw_selector
  getter inner_text
  delegate text, click, send_keys, displayed?, attribute, property, to: element
  delegate session, to: LuckyFlow

  def initialize(@raw_selector : String, text @inner_text : String? = nil)
  end

  @_element : Selenium::Element?

  private def element : Selenium::Element
    @_element ||= FindElement.run(session, selector, inner_text)
  end

  def value
    property("value")
  end

  # Set the text of a form field
  #
  # ```crystal
  # field = el("input[name='comment']")
  #
  # field.fill("Lucky is great!")
  # ```
  def fill(value : String)
    clear
    send_keys value
  end

  # Add text to the end of a field
  #
  # ```crystal
  # field = el("input[name='comment']")
  # field.fill("Lucky is:")
  #
  # field.append(" So much fun!")
  # ```
  def append(value : String)
    send_keys value
  end

  def selector : String
    Selector.new(raw_selector).parse
  end

  # Remove the text from a form field
  def clear
    element.clear
  end
end
