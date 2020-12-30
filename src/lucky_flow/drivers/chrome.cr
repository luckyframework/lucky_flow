abstract class LuckyFlow::Drivers::Chrome < LuckyFlow::Driver
  def start_session : Selenium::Session
    driver.create_session(capabilities)
  rescue e : IO::Error
    retry_start_session(e)
  end

  def stop
    @driver.try(&.stop)
  end

  protected def capabilities
    Selenium::Chrome::Capabilities.new
  end

  @driver : Selenium::Driver?

  private def driver : Selenium::Driver
    @driver ||= begin
      service = Selenium::Service.chrome(driver_path: driver_path)
      Selenium::Driver.for(:chrome, service: service)
    end
  end

  private def driver_path
    LuckyFlow.settings.driver_path || Webdrivers::Chromedriver.install
  rescue err
    raise DriverInstallationError.new(err)
  end
end
