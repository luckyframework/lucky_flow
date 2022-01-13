# Handles starting and stopping server sessions
class LuckyFlow::Server
  getter session : Selenium::Session do
    prepare_screenshot_directory
    driver.start_session
  end

  private getter driver : LuckyFlow::Driver

  # Use LuckyFlow::Server::INSTANCE instead
  def initialize(@driver)
  end

  private def prepare_screenshot_directory
    FileUtils.rm_rf(screenshot_directory)
    FileUtils.mkdir_p(screenshot_directory)
  end

  private def screenshot_directory
    LuckyFlow.settings.screenshot_directory
  end

  def reset : Nil
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown : Nil
    @session.try &.delete
    @driver.try &.stop
  end
end
