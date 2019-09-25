require "spec"
require "http"
require "../src/lucky_flow"
require "./support/**"

# NOTE: specs must be ran with `--no-debug`. https://github.com/crystal-lang/crystal/issues/8228
module Spec
  def self.run
    start_time = Time.monotonic

    at_exit do
      run_filters
      root_context.run
    ensure
      LuckyFlow.shutdown
      elapsed_time = Time.monotonic - start_time
      root_context.finish(elapsed_time, @@aborted)
      exit 1 unless root_context.succeeded && !@@aborted
    end
  end
end

include LuckyFlow::Expectations

server = TestServer.new(3002)

Spec.before_each do
  TestServer.reset
end

LuckyFlow.configure do |settings|
  settings.base_uri = "http://localhost:3002"
  settings.stop_retrying_after = 40.milliseconds
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
