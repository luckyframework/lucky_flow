abstract class LuckyFlow::Selenium::Driver < LuckyFlow::Driver
  SESSION_RETRY_LIMIT = 2.seconds

  @driver : ::Selenium::Driver?
  @capabilities : ::Selenium::Capabilities

  private getter session : ::Selenium::Session { start_session }

  protected def initialize(@capabilities)
  end

  def screenshot(path : String)
    Dir.mkdir_p(File.dirname(path))
    session.screenshot(path)
  end

  def visit(url : String)
    session.document_manager.execute_script("window.__lucky_flow_pending = true;") if @session
    session.navigate_to(url)
    wait_for_ready
  end

  private def wait_for_ready
    retry_interval = 10.milliseconds
    retries = (LuckyFlow.settings.stop_retrying_after / retry_interval).to_i
    script = "return !window.__lucky_flow_pending && document.readyState === 'complete';"

    retries.times do
      return if session.document_manager.execute_script(script) == "true"
      sleep(retry_interval)
    end
  end

  def window_size : NamedTuple(width: Int64?, height: Int64?)
    result = session.window_manager.window_rect
    {width: result.width, height: result.height}
  end

  def maximize_window
    session.window_manager.maximize
  end

  def resize_window(width : Int64?, height : Int64?)
    session.window_manager.resize_window(width: width, height: height)
  end

  def accept_alert
    session.alert_manager.accept_alert
  end

  def dismiss_alert
    session.alert_manager.dismiss_alert
  end

  def hover(element : LuckyFlow::Element)
    if midpoint = element.midpoint
      session.move_to(**midpoint)
    end
  end

  def find_css(query : String) : Array(LuckyFlow::Element)
    find_elements(:css, query)
  end

  def find_xpath(query : String) : Array(LuckyFlow::Element)
    find_elements(:xpath, query)
  end

  def current_url : String
    session.current_url
  end

  def add_cookie(key : String, value : String)
    session.cookie_manager.add_cookie(key, value)
  end

  def get_cookie(key : String) : String?
    session.cookie_manager.get_cookie(key).value
  end

  def html : String
    session.document_manager.page_source
  end

  def reset : Nil
    @session.try do |session|
      session.navigate_to("about:blank")
      session.cookie_manager.delete_all_cookies
    end
  end

  def stop
    @driver.try(&.stop)
  end

  def shutdown : Nil
    @session.try &.delete
    stop
  end

  private def start_session : ::Selenium::Session
    retry_interval = 100.milliseconds
    retries = (SESSION_RETRY_LIMIT / retry_interval).to_i

    retries.times do
      return driver.create_session(@capabilities)
    rescue IO::Error
      sleep(retry_interval)
    end

    driver.create_session(@capabilities)
  end

  private def find_elements(
    strategy : Symbol,
    query : String,
  ) : Array(LuckyFlow::Element)
    session.find_elements(strategy, query).map do |element|
      LuckyFlow::Selenium::Element
        .new(self, query, element)
        .as(LuckyFlow::Element)
    end
  end
end
