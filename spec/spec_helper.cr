require "spec"
require "http"
require "../src/lucky_flow"
require "./support/**"

include LuckyFlow::Expectations

server = TestServer.new(3002)

Spec.before_each do
  TestServer.reset
end

LuckyFlow.configure do |settings|
  settings.base_uri = "http://localhost:3002"
  settings.stop_retrying_after = 40.milliseconds
end

Spec.after_suite do
  LuckyFlow.shutdown
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
