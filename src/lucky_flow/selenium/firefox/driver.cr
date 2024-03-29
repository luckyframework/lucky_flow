module LuckyFlow::Selenium
  class Firefox::Driver < Driver
    private getter driver : ::Selenium::Driver do
      service = ::Selenium::Service.firefox(driver_path: driver_path)
      ::Selenium::Driver.for(:firefox, service: service)
    end

    def initialize(&)
      super ::Selenium::Firefox::Capabilities.new
      yield @capabilities.as(::Selenium::Firefox::Capabilities)
    end

    private def driver_path
      LuckyFlow.settings.driver_path || Webdrivers::Geckodriver.install
    rescue e
      raise DriverInstallationError.new(e)
    end
  end
end

LuckyFlow::Registry.register :firefox do
  LuckyFlow::Selenium::Firefox::Driver.new { }
end

LuckyFlow::Registry.register :headless_firefox do
  LuckyFlow::Selenium::Firefox::Driver.new do |config|
    remote_debugging_port = ENV.fetch("FIREFOX_REMOTE_DEBUGGING_PORT", "9222")
    config.firefox_options.args = [
      "--no-sandbox",
      "--headless",
      "--disable-gpu",
      "--disable-software-rasterizer",
      "--disable-dev-shm-usage",
      "--start-debugger-server=#{remote_debugging_port}",
    ]
  end
end
