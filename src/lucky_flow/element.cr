class LuckyFlow::Element
  private getter raw_selector
  getter inner_text
  delegate text, click, send_keys, displayed?, selected?, attribute, property, tag_name, to: element
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
  # ```
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
  # ```
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

  def select_option(value : String)
    select_el = Selenium::Helpers::Select.from_element(element)
    select_el.select_by_value(value)
  end

  def select_options(values : Array(String))
    select_el = Selenium::Helpers::Select.from_element(element)
    raise LuckyFlow::InvalidMultiSelectError.new unless select_el.multiple?

    values.each { |value| select_el.select_by_value(value) }
  end

  def hover
    session.move_to(element)
  end
end
