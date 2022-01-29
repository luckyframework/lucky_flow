abstract class LuckyFlow::Selenium::Driver < LuckyFlow::Driver
  @retry_limit : Time = 2.seconds.from_now
  @driver : ::Selenium::Driver?
  @capabilities : ::Selenium::Capabilities

  private getter session : ::Selenium::Session { start_session }

  protected def initialize(@capabilities)
  end

  def screenshot(path : String)
    FileUtils.mkdir_p(File.dirname(path))
    session.screenshot(path)
  end

  def visit(url : String)
    session.navigate_to(url)
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
    @session.try &.cookie_manager.delete_all_cookies
  end

  def stop
    @driver.try(&.stop)
  end

  def shutdown : Nil
    @session.try &.delete
    stop
  end

  private def start_session : ::Selenium::Session
    driver.create_session(@capabilities)
  rescue e : IO::Error
    retry_start_session(e)
  end

  private def retry_start_session(e)
    if Time.utc <= @retry_limit
      sleep(0.1)
      start_session
    else
      raise e
    end
  end

  private def find_elements(strategy : Symbol, query : String) : Array(LuckyFlow::Element)
    session.find_elements(strategy, query)
      .map { |el| LuckyFlow::Selenium::Element.new(self, query, el).as(LuckyFlow::Element) }
  end
end
