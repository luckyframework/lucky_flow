require "file_utils"
require "http/client"

class LuckyFlow::SeleniumServer
  SELENIUM_SERVER_URL  = "https://selenium-release.storage.googleapis.com/3.11/selenium-server-standalone-3.11.0.jar"
  SELENIUM_SERVER_PATH = "./tmp/selenium-server.jar"

  private property process : Process

  private def initialize
    ensure_java_is_installed
    ensure_selenium_jar_is_downloaded
    @process = start_selenium_server
  end

  def self.start
    new
  end

  private def ensure_java_is_installed
    if !Process.find_executable("java")
      raise <<-ERROR
      Java must be available from the command line to use LuckyFlow.

        ▸ On macOS: brew cask install java
        ▸ On Linux: https://www.java.com/en/download/help/linux_x64_install.xml

      ERROR
    end
  end

  private def ensure_selenium_jar_is_downloaded
    FileUtils.mkdir_p("./tmp/")

    unless File.exists?(SELENIUM_SERVER_PATH)
      HTTP::Client.get(SELENIUM_SERVER_URL) do |response|
        if response.success?
          File.write(SELENIUM_SERVER_PATH, response.body_io)
        else
          raise "Error retrieving Selenium: #{response.body_io}"
        end
      end
    end
  end

  # Helpful code from Ruby's selenium server
  # https://github.com/SeleniumHQ/selenium/blob/5085838e163be17ecc081f18201adeb890fad040/rb/lib/selenium/server.rb#L231
  private def start_selenium_server : Process
    io = IO::Memory.new
    process = Process.new(
      command: "java -jar #{SELENIUM_SERVER_PATH}",
      output: io,
      error: io,
      shell: true
    )
    wait_for_selenium_to_start(io)
    process
  end

  private def wait_for_selenium_to_start(io : IO) : Void
    timeout_after = 2.seconds.from_now
    while Time.new <= timeout_after
      break if up_and_running?(io)
      sleep(0.01)
    end
    raise io.to_s unless up_and_running?(io)
  end

  private def up_and_running?(io)
    io.to_s.includes?("up and running")
  end

  def stop
    process.kill unless process.terminated?
  end
end
