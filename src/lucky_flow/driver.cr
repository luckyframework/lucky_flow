abstract class LuckyFlow::Driver
  @retry_limit : Time = 2.seconds.from_now

  getter session : Selenium::Session do
    prepare_screenshot_directory
    start_session
  end

  abstract def start_session : Selenium::Session
  abstract def stop

  def reset : Nil
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown : Nil
    @session.try &.delete
    stop
  end

  protected def retry_start_session(e)
    if Time.utc <= @retry_limit
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
end
