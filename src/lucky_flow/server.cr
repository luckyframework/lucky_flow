# Handles starting and stopping server sessions
class LuckyFlow::Server
  # This is used so that only one server instance is started
  INSTANCE = new

  @session : Selenium::Session?
  @driver : LuckyFlow::Driver?

  # Use LuckyFlow::Server::INSTANCE instead
  private def initialize
  end

  # Start a new selenium session
  def session : Selenium::Session
    @session ||= begin
      prepare_screenshot_directory
      driver.start_session
    end
  end

  private def prepare_screenshot_directory
    FileUtils.rm_rf(screenshot_directory)
    FileUtils.mkdir_p(screenshot_directory)
  end

  private def screenshot_directory
    LuckyFlow.settings.screenshot_directory
  end

  def reset
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown
    @session.try &.delete
    @driver.try &.stop
  end

  private def driver
    @driver ||= begin
      LuckyFlow.settings.driver.new
    end
  end
end
