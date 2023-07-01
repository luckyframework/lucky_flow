abstract class LuckyFlow::Driver
  abstract def stop
  abstract def reset
  abstract def shutdown
  abstract def screenshot(path : String)
  abstract def visit(url : String)
  abstract def window_size : NamedTuple(width: Int64?, height: Int64?)
  abstract def maximize_window
  abstract def resize_window(width : Int64?, height : Int64?)
  abstract def accept_alert
  abstract def dismiss_alert
  abstract def hover(element : LuckyFlow::Element)
  abstract def find_css(query : String) : Array(LuckyFlow::Element)
  abstract def find_xpath(query : String) : Array(LuckyFlow::Element)
  abstract def current_url : String
  abstract def add_cookie(key : String, value : String)
  abstract def get_cookie(key : String) : String?
  abstract def html : String

  macro unsupported
    method_name = \{{ @def.name.stringify }}
    raise NotSupportedByDriverError.new("#{self.class}##{method_name}")
  end
end
