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
    # args:                     "--headless",
  }

  @session : Selenium::Session?
  @selenium_server : LuckyFlow::SeleniumServer?

  # Use LuckyFlow::Server::INSTANCE instead
  private def initialize
  end

  # Start a new selenium session with Chromedriver
  def session : Selenium::Session
    @session ||= start_new_session
  end

  private def start_new_session : Selenium::Session
    prepare_screenshot_directory
    start_selenium_server
    driver = Selenium::Webdriver.new
    Selenium::Session.new(driver, CAPABILITIES)
  end

  private def prepare_screenshot_directory
    FileUtils.rm_rf(screenshot_directory)
    FileUtils.mkdir_p(screenshot_directory)
  end

  private def screenshot_directory
    LuckyFlow.settings.screenshot_directory
  end

  private def start_selenium_server
    @selenium_server = LuckyFlow::SeleniumServer.start
  end

  def shutdown
    @session.try(&.stop)
    @selenium_server.try(&.stop)
  end
end
