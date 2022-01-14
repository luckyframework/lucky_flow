class LuckyFlow::Webless::Driver < LuckyFlow::Driver
  def self.new(handlers : Array(HTTP::Handler))
    new(HTTP::Server.build_middleware(handlers))
  end

  @browser : LuckyFlow::Webless::Browser

  def initialize(handler : HTTP::Handler)
    @browser = LuckyFlow::Webless::Browser.new(::Webless::Client.new(handler))
  end

  def screenshot(path : String)
    unsupported
  end

  def visit(url : String)
    @browser.visit(url)
  end

  def follow(method : String, url : String)
    @browser.follow(method, url)
  end

  def window_size : NamedTuple(width: Int64?, height: Int64?)
    unsupported
  end

  def maximize_window
    unsupported
  end

  def resize_window(width : Int64?, height : Int64?)
    unsupported
  end

  def accept_alert
    unsupported
  end

  def dismiss_alert
    unsupported
  end

  def hover(element : LuckyFlow::Element)
    unsupported
  end

  def find_css(query : String) : Array(LuckyFlow::Element)
    @browser.find_css(query).map { |el| element(query, el) }
  end

  def find_xpath(query : String) : Array(LuckyFlow::Element)
    @browser.find_xpath(query).map { |el| element(query, el) }
  end

  def current_url : String
    @browser.current_url
  end

  def add_cookie(key : String, value : String)
    @browser.add_cookie(key, value)
  end

  def get_cookie(key : String) : String?
    @browser.get_cookie(key)
  end

  def html : String
    @browser.html
  end

  def submit(request : HTTP::Request)
    @browser.submit(request)
  end

  def reset : Nil
    @browser.reset
  end

  def stop
    # do nothing :shrug:
  end

  def shutdown : Nil
    stop
  end

  private def element(query : String, el : HTML5::Node) : LuckyFlow::Element
    LuckyFlow::Webless::Element.new(self, query, el).as(LuckyFlow::Element)
  end
end
