class TestHandler
  include HTTP::Handler
  private getter routes = {} of String => Proc(HTTP::Server::Context, String)

  def call(context)
    if context.request.resource == "/favicon.ico"
      context.response.print ""
    else
      handler = routes[context.request.resource]
      context.response.content_type = "text/html"
      context.response.print handler.call(context)
    end
  end

  def route(path : String, handler : Proc(HTTP::Server::Context, String))
    routes[path] = handler
  end

  def reset
    routes.clear
  end
end
