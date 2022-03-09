class LuckyFlow::Webless::Browser
  REDIRECT_LIMIT = 5

  @parsed_html : HTML5::Node? = nil

  def initialize(@client : ::Webless::Client)
  end

  def visit(url : String)
    follow("GET", url)
  end

  def follow(method : String, url : String)
    @client.exec(method.upcase, url)
    handle_redirects
    @parsed_html = nil
  end

  def submit(request : HTTP::Request)
    @client.exec(request)
    handle_redirects
    @parsed_html = nil
  end

  def find_css(query : String) : Array(HTML5::Node)
    parsed_html.css(query)
  end

  def find_xpath(query : String) : Array(HTML5::Node)
    parsed_html.xpath_nodes(query)
  end

  def current_url : String
    @client.last_request_url
  end

  def reset
    @client.clear_cookies
  end

  def add_cookie(key : String, value : String)
    @client.cookie_jar[key] = value
  end

  def get_cookie(key : String) : String?
    @client.cookie_jar[key]?
  end

  def html : String
    @client.last_response.body
  end

  private def parsed_html : HTML5::Node
    @parsed_html ||= HTML5.parse(html)
  end

  private def handle_redirects
    REDIRECT_LIMIT.times do
      if @client.last_response.status.redirection?
        @client.follow_redirect!
      else
        return
      end
    end

    if @client.last_response.status.redirection?
      raise LuckyFlow::InfiniteRedirectError.new("Redirected more than #{REDIRECT_LIMIT} times. Could be an infinite redirect loop.")
    end
  end
end
