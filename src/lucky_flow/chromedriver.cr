require "file_utils"
require "http/client"

class LuckyFlow::Chromedriver
  private property process : Process
  getter log_io = IO::Memory.new

  private def initialize(@driver_path : String)
    @process = start_chromedriver
  end

  def self.start(driver_path)
    new(driver_path)
  end

  private def start_chromedriver : Process
    Process.new(
      @driver_path,
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
