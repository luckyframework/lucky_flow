# Handles starting and stopping server sessions
class LuckyFlow::Server
  # This is used so that only one server instance is started
  INSTANCE = new

  CAPABILITIES = Selenium::Chrome::Capabilities.new
  CAPABILITIES.args(["no-sandbox", "headless", "disable-gpu"])

  @retry_limit : Time?
  @session : Selenium::Session?
  @driver : Selenium::Driver?

  # Use LuckyFlow::Server::INSTANCE instead
  private def initialize
  end

  # Start a new selenium session with Chromedriver
  def session : Selenium::Session
    @session ||= create_session
  end

  private def driver : Selenium::Driver
    @driver ||= begin
      service = Selenium::Service.chrome(driver_path: LuckyFlow.settings.chromedriver_path)
      Selenium::Driver.for(:chrome, service: service)
    end
  end

  private def create_session : Selenium::Session
    @retry_limit = 2.seconds.from_now
    prepare_screenshot_directory
    start_session
  end

  # If less than 0.34.0
  {% if compare_versions(Crystal::VERSION, "0.34.0") == -1 %}
    private def start_session
      driver.create_session(CAPABILITIES)
    rescue e : Errno
      retry_start_session(e)
    end
  {% else %}
    private def start_session
      driver.create_session(CAPABILITIES)
    rescue e : IO::Error
      retry_start_session(e)
    end
  {% end %}

  private def retry_start_session(e)
    if Time.utc <= @retry_limit.not_nil!
      sleep(0.1)
      start_session
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

  def reset
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown
    @session.try &.delete
    @driver.try &.stop
  end
end
