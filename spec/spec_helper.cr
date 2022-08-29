require "spec"
require "http"
require "../src/lucky_flow"
require "../src/ext/lucky"
require "../src/ext/avram"
require "../src/ext/authentic"
require "./support/**"

include LuckyFlow::Expectations

LuckyFlow::Registry.register :webless do
  LuckyFlow::Webless::Driver.new(TestServer.middleware)
end

LuckyFlow.default_driver = ENV.fetch("LUCKYFLOW_DRIVER", "webless")

LuckyFlow::Spec.setup

server = TestServer.new(3002)

Spec.before_each do
  TestServer.reset
end

LuckyFlow.configure do |settings|
  settings.base_uri = "http://localhost:3002"
  settings.stop_retrying_after = 40.milliseconds
end

Habitat.raise_if_missing_settings!

Spec.after_suite do
  server.close
end

spawn do
  server.listen
end

def visit_page_with(html) : LuckyFlow
  TestServer.route "/home", html
  flow = LuckyFlow.new
  flow.visit("/home")
  flow
end

def handle_route(path : String, &block : HTTP::Server::Context -> String)
  TestServer.middleware.route(path, block)
end
