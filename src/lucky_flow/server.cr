# Handles starting and stopping server sessions
class LuckyFlow::Server
  # This is used so that only one server instance is started
  INSTANCE = new

  CAPABILITIES = {
    browserName:              "chrome",
    platform:                 "ANY",
    javascriptEnabled:        true,
    takesScreenshot:          true,
    handlesAlerts:            true,
    databaseEnabled:          true,
    locationContextEnabled:   true,
    applicationCacheEnabled:  true,
    browserConnectionEnabled: true,
    cssSelectorsEnabled:      true,
    webStorageEnabled:        true,
    rotatable:                true,
    acceptSslCerts:           true,
    nativeEvents:             true,
    chromeOptions:            {args: ["no-sandbox", "headless", "disable-gpu"]},
  }

  @retry_limit : Time?
  @session : Selenium::Session?
  @chromedriver : LuckyFlow::Chromedriver?

  # Use LuckyFlow::Server::INSTANCE instead
  private def initialize
  end

  # Start a new selenium session with Chromedriver
  def session : Selenium::Session
    @session ||= create_session
  end

  private def create_session : Selenium::Session
    @retry_limit = 2.seconds.from_now
    prepare_screenshot_directory
    start_chromedriver
    start_session
  end

  # If less than 0.34.0
  {% if compare_versions(Crystal::VERSION, "0.34.0") == -1 %}
    private def start_session
      driver = Selenium::Webdriver.new
      Selenium::Session.new(driver, capabilities)
    rescue e : Errno
      retry_start_session(e)
    end
  {% else %}
    private def start_session
      driver = Selenium::Webdriver.new
      Selenium::Session.new(driver, capabilities)
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

  private def start_chromedriver
    @chromedriver ||= LuckyFlow::Chromedriver.start
  end

  def reset
    @session.try &.cookies.clear
  end

  def shutdown
    @session.try(&.stop)
    @chromedriver.try(&.stop)
  end
end
