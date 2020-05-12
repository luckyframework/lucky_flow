# Handles starting and stopping server sessions
class LuckyFlow::Server
  # This is used so that only one server instance is started
  INSTANCE = new

  CAPABILITIES = Selenium::Chrome::Capabilities.new
  CAPABILITIES.args(["no-sandbox", "headless", "disable-gpu"])

  @retry_limit : Time?
  @session : Selenium::Session?
  @chromedriver : LuckyFlow::Chromedriver?
  @driver : Selenium::Driver?

  # Use LuckyFlow::Server::INSTANCE instead
  private def initialize
  end

  # Start a new selenium session with Chromedriver
  def session : Selenium::Session
    @session ||= create_session(driver)
  end

  private def driver : Selenium::Driver
    @driver ||= Selenium::Driver.for(:chrome, base_url: "http://localhost:4444/wd/hub")
  end

  private def create_session(driver) : Selenium::Session
    @retry_limit = 2.seconds.from_now
    prepare_screenshot_directory
    start_chromedriver
    start_session(driver)
  end

  # If less than 0.34.0
  {% if compare_versions(Crystal::VERSION, "0.34.0") == -1 %}
    private def start_session(driver)
      driver.create_session(CAPABILITIES)
    rescue e : Errno
      retry_start_session(e, driver)
    end
  {% else %}
    private def start_session(driver)
      driver.create_session(CAPABILITIES)
    rescue e : IO::Error
      retry_start_session(e, driver)
    end
  {% end %}

  private def retry_start_session(e, driver)
    if Time.utc <= @retry_limit.not_nil!
      sleep(0.1)
      start_session(driver)
    else
      raise e
    end
  end

  private def prepare_screenshot_directory
    FileUtils.rm_rf(screenshot_directory)
    FileUtils.mkdir_p(screenshot_directory)
  end

  private def screenshot_directory
    LuckyFlow.settings.screenshot_directory
  end

  private def browser_binary
    LuckyFlow.settings.browser_binary
  end

  private def capabilities
    if browser_binary.nil?
      CAPABILITIES
    else
      CAPABILITIES.merge({
        chromeOptions: {
          args:   CAPABILITIES[:chromeOptions][:args],
          binary: browser_binary,
        },
      })
    end
  end

  private def start_chromedriver
    @chromedriver ||= LuckyFlow::Chromedriver.start(LuckyFlow.settings.chromedriver_path)
  end

  def reset
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown
    @session.try &.delete
    @chromedriver.try(&.stop)
  end
end
