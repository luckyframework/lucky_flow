class LuckyFlow::Selenium::Element < LuckyFlow::Element
  delegate send_keys, to: @inner_element

  @inner_element : ::Selenium::Element

  def initialize(driver, raw_selector, @inner_element)
    super driver, raw_selector
  end

  def text : String
    @inner_element.text
  end

  def displayed? : Bool
    @inner_element.displayed?
  end

  def selected? : Bool
    @inner_element.selected?
  end

  def checked? : Bool
    selected?
  end

  def attribute(name : String) : String?
    @inner_element.attribute(name)
  end

  def property(name : String) : String?
    @inner_element.property(name)
  end

  def tag_name : String
    @inner_element.tag_name
  end

  def clear
    @inner_element.clear
  end

  def click
    @inner_element.click
  end

  # To set the value of date inputs correctly
  # you must put the year last
  # but it still submits the form with the date first
  # ...any questions?
  def fill(value : Time)
    fill(value.to_s("%m-%d-%Y"))
  end

  def send_keys(keys : Array(String | Symbol))
    @inner_element.send_keys(keys)
  end

  def select_option(value : String)
    select_el = ::Selenium::Helpers::Select.from_element(@inner_element)
    select_el.select_by_value(value)
  end

  def select_options(values : Array(String))
    select_el = ::Selenium::Helpers::Select.from_element(@inner_element)
    raise LuckyFlow::InvalidMultiSelectError.new unless select_el.multiple?

    values.each { |value| select_el.select_by_value(value) }
  end

  def midpoint : NamedTuple(x: Int32, y: Int32)?
    midpoint = @inner_element.rect.try(&.midpoint)
    return if midpoint.nil?

    {x: midpoint.x, y: midpoint.y}
  end
end
