require "selenium"
require "habitat"
require "webdrivers"
require "webless"
require "html5"

class LuckyFlow; end

require "./lucky_flow/**"
require "file_utils"
require "./ext/spec/item"

class LuckyFlow
  include LuckyFlow::Expectations

  Habitat.create do
    setting screenshot_directory : String = "./tmp/screenshots"
    setting base_uri : String
    setting retry_delay : Time::Span = 10.milliseconds
    setting stop_retrying_after : Time::Span = 1.second
    setting driver_path : String?
  end

  def self.default_driver=(value : String)
    LuckyFlow::Registry.default_driver = value
  end

  def self.driver : LuckyFlow::Driver
    LuckyFlow::Registry.current_driver ||= LuckyFlow::Registry.get_driver
  end

  def self.driver(name : String) : LuckyFlow::Driver
    LuckyFlow::Registry.current_driver = LuckyFlow::Registry.get_driver(name)
  end

  def self.shutdown : Nil
    LuckyFlow::Registry.shutdown_all
  end

  def self.use_default_driver
    LuckyFlow::Registry.current_driver = nil
  end

  def self.reset : Nil
    LuckyFlow::Registry.current_driver.try(&.reset)
  end

  def visit(path : String)
    driver.visit("#{settings.base_uri}#{path}")
  end

  def open_screenshot(process = Process, time = Time.utc, fullsize = false) : Void
    filename = generate_screenshot_filename(time)
    take_screenshot(filename, fullsize)
    process.new(command: "#{open_command(process)} #{filename}", shell: true)
  end

  def take_screenshot(filename : String = generate_screenshot_filename, fullsize : Bool = true)
    if fullsize
      with_fullsized_page { driver.screenshot(filename) }
    else
      driver.screenshot(filename)
    end
  end

  private def generate_screenshot_filename(time : Time = Time.utc)
    "#{settings.screenshot_directory}/#{time.to_unix}.png"
  end

  def expand_page_to_fullsize
    driver.maximize_window
  end

  def with_fullsized_page(&)
    original_size = driver.window_size
    expand_page_to_fullsize
    yield
  ensure
    driver.resize_window(**original_size) if original_size
  end

  private def open_command(process) : String
    ["open", "xdg-open", "kde-open", "gnome-open"].find do |command|
      !!process.find_executable(command)
    end || raise "Could not find a way to open the screenshot"
  end

  def click(css_selector : String)
    el(css_selector).click
  end

  # Set the text of a form field, clearing any existing text
  #
  # ```
  # fill("comment:body", with: "Lucky is great!")
  # ```
  def fill(name_attr : String, with value)
    fill(field(name_attr), with: value)
  end

  def fill(element : Element, with value)
    element.fill(value)
  end

  # Add text to the end of a field
  #
  # ```
  # fill("comment:body", with: "Lucky is:")
  #
  # append("comment:body", " So much fun!")
  # ```
  def append(name_attr : String, with value : String)
    field(name_attr).append(value)
  end

  # Select an option from a select element
  #
  # ```
  # select("post:category", value: "rant")
  # ```
  #
  # If given an Array(String), the select is assumed to have the 'multiple' attribute
  # and will raise a `LuckyFlow::InvalidMultiSelectError` if it doesn't.
  #
  # ```
  # select("post:tags", value: ["rant", "technology"])
  # ```
  #
  def select(name_attr : String, value : Array(String) | String)
    self.select(field(name_attr), value: value)
  end

  def select(element : Element, value : String)
    element.select_option(value)
  end

  def select(element : Element, value : Array(String))
    element.select_options(value)
  end

  def el(css_selector : String, text : String) : LuckyFlow::Element
    LuckyFlow::FindElement.run(driver, css_selector, text)
  end

  def el(css_selector : String) : LuckyFlow::Element
    LuckyFlow::FindElement.run(driver, css_selector)
  end

  def field(name_attr : String) : LuckyFlow::Element
    el("[name='#{name_attr}']")
  end

  def html : String
    driver.html
  end

  def current_path
    url = driver.current_url
    URI.parse(url).path
  end

  def accept_alert
    driver.accept_alert
  end

  def dismiss_alert
    driver.dismiss_alert
  end

  def pause
    puts "\nPausing to debug... (press enter to continue)"
    STDIN.gets
  end

  def driver : LuckyFlow::Driver
    self.class.driver
  end
end
