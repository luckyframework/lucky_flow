require "../spec_helper"

private class RaisingDriver < LuckyFlow::Driver
  getter find_css_calls = 0

  def initialize(@error_code : String, @error_message : String)
  end

  def find_css(query : String) : Array(LuckyFlow::Element)
    @find_css_calls += 1
    # Only the first lookup fails, like a page that settles after navigating.
    return [] of LuckyFlow::Element if find_css_calls > 1
    raise Selenium::Error.from_json({error: @error_code, message: @error_message, stacktrace: ""}.to_json)
  end

  def stop; end

  def reset; end

  def shutdown; end

  def screenshot(path : String); end

  def visit(url : String); end

  def window_size : NamedTuple(width: Int64?, height: Int64?)
    {width: nil, height: nil}
  end

  def maximize_window; end

  def resize_window(width : Int64?, height : Int64?); end

  def accept_alert; end

  def dismiss_alert; end

  def hover(element : LuckyFlow::Element); end

  def find_xpath(query : String) : Array(LuckyFlow::Element)
    [] of LuckyFlow::Element
  end

  def current_url : String
    ""
  end

  def add_cookie(key : String, value : String); end

  def get_cookie(key : String) : String?
  end

  def html : String
    ""
  end
end

describe LuckyFlow::FindElement do
  {
    {"stale element reference", "element is not attached to the page document"},
    {"unknown error", "Node with given id does not belong to the document"},
  }.each do |(code, message)|
    it "retries until not found when Selenium reports: #{message}" do
      driver = RaisingDriver.new(code, message)

      expect_raises(LuckyFlow::ElementNotFoundError) do
        LuckyFlow::FindElement.run(driver, "@heading")
      end
    end
  end

  it "re-raises other Selenium errors" do
    driver = RaisingDriver.new("invalid selector", "bad selector")

    expect_raises(Selenium::Error) do
      LuckyFlow::FindElement.run(driver, "@heading")
    end
    driver.find_css_calls.should eq 1
  end
end
