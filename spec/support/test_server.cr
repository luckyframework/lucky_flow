class TestServer
  delegate listen, close, to: @server
  class_property routes = {} of String => String

  def initialize(port : Int32)
    @server = HTTP::Server.new do |context|
      if context.request.resource == "/favicon.ico"
        context.response.print ""
      else
        html = self.class.routes[context.request.resource]
        context.response.content_type = "text/html"
        context.response.print html
      end
    end
    @server.bind_tcp port: port
  end

  def self.route(path : String, html : String)
    routes[path] = html
  end

  def self.reset
    self.routes = {} of String => String
  end
end
