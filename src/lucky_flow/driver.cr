abstract class LuckyFlow::Driver
  @retry_limit : Time = 2.seconds.from_now

  getter session : Selenium::Session { start_session }

  abstract def start_session : Selenium::Session
  abstract def stop

  def reset : Nil
    @session.try &.cookie_manager.delete_all_cookies
  end

  def shutdown : Nil
    @session.try &.delete
    stop
  end

  def screenshot(path : String)
    FileUtils.mkdir_p(File.dirname(path))
    session.screenshot(path)
  end

  protected def retry_start_session(e)
    if Time.utc <= @retry_limit
      sleep(0.1)
      start_session
    else
      raise e
    end
  end
end
