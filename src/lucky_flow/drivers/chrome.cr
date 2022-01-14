module LuckyFlow::Drivers
  class Chrome < Selenium
    private getter driver : ::Selenium::Driver do
      service = ::Selenium::Service.chrome(driver_path: driver_path)
      ::Selenium::Driver.for(:chrome, service: service)
    end

    def initialize(&block)
      super ::Selenium::Chrome::Capabilities.new
      yield @capabilities.as(::Selenium::Chrome::Capabilities)
    end

    private def driver_path
      LuckyFlow.settings.driver_path || Webdrivers::Chromedriver.install
    rescue err
      raise DriverInstallationError.new(err)
    end
  end
end

LuckyFlow::Registry.register :chrome do
  LuckyFlow::Drivers::Chrome.new { }
end

LuckyFlow::Registry.register :headless_chrome do
  LuckyFlow::Drivers::Chrome.new do |config|
    config.chrome_options.args = ["no-sandbox", "headless", "disable-gpu"]
  end
end
