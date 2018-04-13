require "spec"
require "http"
require "../src/lucky_flow"
require "./support/**"

include LuckyFlow::Expectations

server = TestServer.new(3002)

Spec.before_each do
  TestServer.reset
end

LuckyFlow.configure do
  settings.url_root = "localhost:3002"
  settings.stop_retrying_after = 40.milliseconds
end

spawn do
  server.listen
end

at_exit do
  LuckyFlow.shutdown
  server.close
end
