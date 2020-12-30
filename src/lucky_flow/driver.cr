abstract class LuckyFlow::Driver
  @retry_limit : Time = 2.seconds.from_now

  abstract def start_session : Selenium::Session

  protected def retry_start_session(e)
    if Time.utc <= @retry_limit
      sleep(0.1)
      start_session
    else
      raise e
    end
  end
end
