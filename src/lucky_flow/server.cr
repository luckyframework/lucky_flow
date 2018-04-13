# Handles starting and stopping server sessions
class LuckyFlow::Server
  # This is used so that only one server instance is started
  INSTANCE = new

  CAPABILITIES = {
    browserName:              "chrome",
    version:                  "",
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
  @selenium_server : Process?

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
    io = IO::Memory.new
    @selenium_server ||= Process.new(
      command: "selenium-server",
      output: io,
      error: io
    )
    wait_for_selenium_to_start(io)
  end

  private def wait_for_selenium_to_start(io : IO)
    timeout_after = 2.seconds.from_now
    while Time.new <= timeout_after
      break if io.to_s.includes?("up and running")
      sleep(0.01)
    end
  end

  def shutdown
    @session.try(&.stop)
    @selenium_server.try do |server|
      server.kill unless server.terminated?
    end
  end
end
