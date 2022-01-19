class TestHandler
  include HTTP::Handler
  private getter routes = {} of String => String

  def call(context)
    if context.request.resource == "/favicon.ico"
      context.response.print ""
    else
      html = routes[context.request.resource]
      context.response.content_type = "text/html"
      context.response.print html
    end
  end

  def route(path : String, html : String)
    routes[path] = html
  end

  def reset
    routes.clear
  end
end
