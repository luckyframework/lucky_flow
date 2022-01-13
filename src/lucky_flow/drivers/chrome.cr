class LuckyFlow::Drivers::Chrome < LuckyFlow::Driver
  private getter driver : Selenium::Driver do
    service = Selenium::Service.chrome(driver_path: driver_path)
    Selenium::Driver.for(:chrome, service: service)
  end

  @capabilities : Selenium::Chrome::Capabilities

  def self.new
    new do |config|
      config.chrome_options.args = args
      config.chrome_options.binary = LuckyFlow.settings.browser_binary
    end
  end

  def self.args : Array(String)
    [] of String
  end

  def initialize(&block)
    @capabilities = Selenium::Chrome::Capabilities.new
    yield @capabilities
  end

  def start_session : Selenium::Session
    driver.create_session(@capabilities)
  rescue e : IO::Error
    retry_start_session(e)
  end

  def stop
    @driver.try(&.stop)
  end

  private def driver_path
    LuckyFlow.settings.driver_path || Webdrivers::Chromedriver.install
  rescue err
    raise DriverInstallationError.new(err)
  end
end
