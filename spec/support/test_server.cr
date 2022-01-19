class TestServer
  delegate listen, close, to: @server
  class_getter middleware = TestHandler.new

  def initialize(port : Int32)
    @server = HTTP::Server.new(@@middleware)
    @server.bind_tcp port: port
  end

  def self.route(path : String, html : String)
    middleware.route(path, ->(_context : HTTP::Server::Context) { html })
  end

  def self.reset
    middleware.reset
  end
end
