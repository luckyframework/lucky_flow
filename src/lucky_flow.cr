require "selenium"
require "habitat"

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
    setting chromedriver_path : String? = nil
  end

  def visit(path : String)
    session.url = "#{settings.base_uri}#{path}"
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
    session.url = url
  end

  def open_screenshot(process = Process, time = Time.now, fullsize = false) : Void
    filename = "#{settings.screenshot_directory}/#{time.to_unix}.png"
    if fullsize
      with_fullsized_page { session.save_screenshot(filename) }
    else
      session.save_screenshot(filename)
    end
    process.new(command: "#{open_command(process)} #{filename}", shell: true)
  end

  def expand_page_to_fullsize
    width = session.execute("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);").as_i
    height = session.execute("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);").as_i
    window = session.window
    window.resize_to(width + 100, height + 100)
  end

  def with_fullsized_page(&block)
    original_size = session.window.rect
    expand_page_to_fullsize
    yield
  ensure
    session.window.rect = original_size
  end

  private def open_command(process) : String
    ["open", "xdg-open", "kde-open", "gnome-open"].find do |command|
      !!process.find_executable(command)
    end || raise "Could not find a way to open the screenshot"
  end

  def click(css_selector : String)
    el(css_selector).click
  end

  def fill(name_attr : String, with value : String)
    field(name_attr).fill(value)
  end

  # Fill a form created by Lucky that uses a LuckyRecord::Form
  #
  # Note that Lucky and LuckyRecord are required to use this method
  #
  # ```
  # fill_form QuestionForm,
  #   title: "Hello there!",
  #   body: "Just wondering what day it is"
  # ```
  def fill_form(
    form : LuckyRecord::Form.class | LuckyRecord::VirtualForm.class,
    **fields_and_values
  )
    fields_and_values.each do |name, value|
      fill "#{form.form_name}:#{name}", with: value
    end
  end

  def el(css_selector : String, text : String)
    Element.new(session, css_selector, text)
  end

  def el(css_selector : String)
    Element.new(session, css_selector)
  end

  def field(name_attr : String)
    Element.new(session, "[name='#{name_attr}']")
  end

  def session
    SERVER.session
  end

  def self.shutdown
    SERVER.shutdown
  end

  def self.reset
    SERVER.reset
  end
end
