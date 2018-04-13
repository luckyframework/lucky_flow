class TestServer
  delegate listen, close, to: @server
  class_property routes = {} of String => String

  def initialize(port : Int32)
    @server = HTTP::Server.new(port) do |context|
      if context.request.resource == "/favicon.ico"
        context.response.print ""
      else
        html = self.class.routes[context.request.resource]
        context.response.content_type = "text/html"
        context.response.print html
      end
    end
  end

  def self.route(path : String, html : String)
    routes[path] = html
  end

  def self.reset
    self.routes = {} of String => String
  end
end
