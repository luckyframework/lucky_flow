class LuckyFlow::Webless::Element < LuckyFlow::Element
  VISIBILITY_XPATH = "boolean(./ancestor-or-self::*[(((./@style[(contains(., 'display:none') or contains(., 'display: none'))] or ./@hidden) or ((name(.) = 'script') or (name(.) = 'head'))) or (not(./self::summary) and ./parent::details[not(./@open)]))])"

  protected getter inner_element : HTML5::Node

  def initialize(driver, raw_selector, @inner_element)
    super driver, raw_selector
  end

  def text : String
    @inner_element.inner_text
  end

  def value
    if tag_name == "select"
      selected_options = @inner_element.xpath_nodes(".//option[@selected]")
      if multiple?
        selected_options.map { |option| option["value"]? || option.inner_text }
      else
        option = selected_options.first? || @inner_element.xpath(".//option")
        raise "expected select to contain an option" if option.nil?
        option["value"]?.try(&.val) || option.inner_text
      end
    else
      attribute("value")
    end
  end

  def click
    if link?
      method = attribute("data-method") || "get"
      driver.as(LuckyFlow::Webless::Driver).follow(method, attribute("href").to_s)
    elsif submits? && (f = form)
      LuckyFlow::Webless::Form.new(f, @inner_element).submit(driver.as(LuckyFlow::Webless::Driver))
    elsif checkable?
      check
    end
  end

  def fill(value : String)
    if input_field? || textarea?
      set_input(value)
    end
  end

  def append(value : String)
    find_or_create_attr("value").val += value
  end

  def send_keys(keys : Array(String | Symbol))
    append(keys.join)
  end

  def displayed? : Bool
    return false if tag_name == "input" && attribute("type") == "hidden"
    return false if tag_name == "template"

    @driver.find_xpath(VISIBILITY_XPATH).empty?
  end

  def selected? : Bool
    attribute("selected") == "selected"
  end

  def checked? : Bool
    attribute("checked") == "checked"
  end

  def attribute(name : String) : String?
    attr = _attribute(name)
    val = attr.try(&.val)
    if attr.nil? && name == "value"
      val = ""
    end

    val
  end

  def remove_attribute(name : String, element : HTML5::Node = @inner_element)
    element.attr.reject! { |at| at.key == name }
  end

  def property(name : String) : String?
    attribute(name)
  end

  def tag_name : String
    @inner_element.data
  end

  def clear
    _attribute("value").try(&.val=(""))
  end

  def select_option(value : String)
    @inner_element.xpath_nodes(".//option[@selected]")
      .each { |node| remove_attribute("selected", node) }

    @inner_element.xpath(".//option[@value='#{value}']")
      .try { |el| find_or_create_attr("selected", el).val = "selected" }
  end

  def select_options(values : Array(String))
    raise LuckyFlow::InvalidMultiSelectError.new unless multiple?

    @inner_element.xpath_nodes(".//option[@selected]")
      .each { |node| remove_attribute("selected", node) }

    values.each do |value|
      @inner_element.xpath(".//option[@value='#{value}']")
        .try { |el| find_or_create_attr("selected", el).val = "selected" }
    end
  end

  def midpoint : {x: Int32, y: Int32}?
    unsupported
  end

  private def link? : Bool
    tag_name == "a" && !!attribute("href")
  end

  private def checkable? : Bool
    tag_name == "input" && ["checkbox", "radio"].includes?(attribute("type"))
  end

  private def _attribute(name : String, element = @inner_element) : HTML5::Attribute?
    element[name]?
  end

  private def input_field? : Bool
    tag_name == "input"
  end

  private def set_input(value : String)
    find_or_create_attr("value").val = value
  end

  private def find_or_create_attr(name : String, element = @inner_element) : HTML5::Attribute
    attr = _attribute(name, element)
    if attr.nil?
      attr = HTML5::Attribute.new(key: name)
      element.attr << attr
    end

    attr
  end

  private def multiple?
    !_attribute("multiple").nil?
  end

  private def textarea? : Bool
    tag_name == "textarea"
  end

  def checkbox? : Bool
    attribute("type") == "checkbox"
  end

  def radio? : Bool
    attribute("type") == "radio"
  end

  private def submits? : Bool
    type = attribute("type")
    (tag_name == "input" && type == "submit") || (tag_name == "button" && (type.nil? || type == "submit"))
  end

  private def form : HTML5::Node?
    @inner_element.xpath(".//ancestor::form[1]")
  end

  def check
    if checkbox?
      set_checkbox(!checked?)
    elsif radio?
      set_radio
    end
  end

  def set_radio
    if name = attribute("name")
      driver.find_xpath("//input[(./@name = '#{name}')]")
        .each { |node| remove_attribute("checked", node.as(LuckyFlow::Webless::Element).inner_element) }
    end

    checked = find_or_create_attr("checked")
    checked.val = "checked"
  end

  def set_checkbox(value : Bool)
    if value
      checked = find_or_create_attr("checked")
      checked.val = "checked"
    else
      remove_attribute("checked")
    end
  end
end
