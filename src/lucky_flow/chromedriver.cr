require "file_utils"
require "http/client"

class LuckyFlow::Chromedriver
  private property process : Process
  getter log_io = IO::Memory.new

  private def initialize
    @process = start_chromedriver
  end

  def self.start
    new
  end

  private def start_chromedriver : Process
    driver_path = LuckyFlow.settings.chromedriver_path ||
                  Process.find_executable("chromedriver") ||
                  "#{__DIR__}/../../vendor/chromedriver-75-#{os}"
    Process.new(
      driver_path.as(String),
      ["--port=4444", "--url-base=/wd/hub"],
      output: log_io,
      error: STDERR,
      shell: spawn_in_shell?
    )
  end

  private def spawn_in_shell?
    {% if flag?(:linux) %}
      false
    {% else %}
      true
    {% end %}
  end

  private def os
    {% if flag?(:linux) %}
      "linux64"
    {% elsif flag?(:darwin) %}
      "mac64"
    {% else %}
      raise "This OS is not supported yet."
    {% end %}
  end

  def stop
    process.kill unless process.terminated?
  end
end
