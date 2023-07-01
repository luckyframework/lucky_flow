abstract class LuckyFlow::Element
  getter driver : LuckyFlow::Driver
  getter raw_selector : String

  abstract def text : String
  abstract def click
  abstract def send_keys(keys : Array(String | Symbol))
  abstract def displayed? : Bool
  abstract def selected? : Bool
  abstract def checked? : Bool
  abstract def attribute(name : String) : String?
  abstract def property(name : String) : String?
  abstract def tag_name : String
  abstract def clear
  abstract def select_option(value : String)
  abstract def select_options(values : Array(String))
  abstract def midpoint : {x: Int32, y: Int32}?

  private def initialize(@driver, @raw_selector)
  end

  def value
    property("value")
  end

  def send_keys(key : String)
    send_keys([key])
  end

  def attribute(name : Symbol) : String?
    attribute(name.to_s)
  end

  def property(name : Symbol) : String?
    property(name.to_s)
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

  def fill(value : Time)
    fill(value.to_s("%Y-%m-%d"))
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

  def hover
    driver.hover(self)
  end

  macro unsupported
    method_name = \{{ @def.name.stringify }}
    raise NotSupportedByElementError.new("#{self.class}##{method_name}")
  end
end
