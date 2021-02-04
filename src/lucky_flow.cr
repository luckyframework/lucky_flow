require "selenium"
require "habitat"
require "webdrivers"

class LuckyFlow; end

require "./lucky_flow/**"
require "file_utils"

class LuckyFlow
  include LuckyFlow::Expectations
  SERVER = LuckyFlow::Server::INSTANCE

  Habitat.create do
    setting screenshot_directory : String = "./tmp/screenshots"
    setting base_uri : String
    setting retry_delay : Time::Span = 10.milliseconds
    setting stop_retrying_after : Time::Span = 1.second
    setting driver_path : String?
    setting browser_binary : String? = nil
    setting driver : LuckyFlow::Driver.class = LuckyFlow::Drivers::HeadlessChrome
  end

  def HabitatSettings.chromedriver_path=(_chromedriver_path)
    {% raise "'chromedriver_path' has been renamed to 'driver_path'" %}
  end

  def visit(path : String)
    session.navigate_to("#{settings.base_uri}#{path}")
  end

  def visit(action : Lucky::Action.class, as user : User? = nil)
    visit(action.route, as: user)
  end

  def visit(route_helper : Lucky::RouteHelper, as user : User? = nil)
    url = route_helper.url
    uri = URI.parse(url)
    if uri.query && user
      url += "&backdoor_user_id=#{user.id}"
    elsif uri.query.nil? && user
      url += "?backdoor_user_id=#{user.id}"
    end
    session.navigate_to(url)
  end

  def open_screenshot(process = Process, time = Time.utc, fullsize = false) : Void
    filename = generate_screenshot_filename(time)
    take_screenshot(filename, fullsize)
    process.new(command: "#{open_command(process)} #{filename}", shell: true)
  end

  def take_screenshot(filename : String = generate_screenshot_filename, fullsize : Bool = true)
    if fullsize
      with_fullsized_page { session.screenshot(filename) }
    else
      session.screenshot(filename)
    end
  end

  private def generate_screenshot_filename(time : Time = Time.utc)
    "#{settings.screenshot_directory}/#{time.to_unix}.png"
  end

  def expand_page_to_fullsize
    width = session.document_manager.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);").to_i64
    height = session.document_manager.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);").to_i64
    session.window_manager.resize_window(width: width + 100, height: height + 100)
  end

  def with_fullsized_page(&block)
    original_size = session.window_manager.window_rect
    expand_page_to_fullsize
    yield
  ensure
    session.window_manager.set_window_rect(original_size)
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
  def fill(name_attr : String, with value : String)
    fill(field(name_attr), with: value)
  end

  def fill(element : Element, with value : String)
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

  # Fill a form created by Lucky that uses an Avram::SaveOperation
  #
  # Note that Lucky and Avram are required to use this method
  #
  # ```
  # fill_form QuestionForm,
  #   title: "Hello there!",
  #   body: "Just wondering what day it is"
  # ```
  def fill_form(
    form : Avram::SaveOperation.class | Avram::Operation.class,
    **fields_and_values
  )
    fields_and_values.each do |name, value|
      element = field("#{form.param_key}:#{name}")
      if element.tag_name == "select"
        self.select(element, value)
      else
        self.fill(element, with: value)
      end
    end
  end

  def el(css_selector : String, text : String)
    Element.new(css_selector, text)
  end

  def el(css_selector : String)
    Element.new(css_selector)
  end

  def field(name_attr : String)
    Element.new("[name='#{name_attr}']")
  end

  def current_path
    url = session.current_url
    URI.parse(url).path
  end

  def accept_alert
    session.alert_manager.accept_alert
  end

  def dismiss_alert
    session.alert_manager.dismiss_alert
  end

  def pause
    puts "\nPausing to debug... (press enter to continue)"
    STDIN.gets
  end

  def session
    self.class.session
  end

  def self.session
    SERVER.session
  end

  def self.shutdown
    SERVER.shutdown
  end

  def self.reset
    SERVER.reset
  end
end
