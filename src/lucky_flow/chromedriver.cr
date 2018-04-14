require "file_utils"
require "http/client"

class LuckyFlow::Chromedriver
  private property process : Process
  getter log_io = IO::Memory.new

  private def initialize
    ensure_chromedriver_is_installed
    @process = start_chromedriver
  end

  def self.start
    new
  end

  private def ensure_chromedriver_is_installed
    if !Process.find_executable("chromedriver")
      raise <<-ERROR
      Chromedriver must be available from the command line to use LuckyFlow.

        ▸ On macOS: brew install chromedriver
        ▸ On Linux: https://makandracards.com/makandra/29465-install-chromedriver-on-linux

      ERROR
    end
  end

  private def start_chromedriver : Process
    Process.new(
      "chromedriver",
      ["--port=4444", "--url-base=/wd/hub"],
      output: log_io,
      error: STDERR,
      shell: true
    )
  end

  def stop
    process.kill unless process.terminated?
  end
end
