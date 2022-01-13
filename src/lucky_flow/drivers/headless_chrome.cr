class LuckyFlow::Drivers::HeadlessChrome < LuckyFlow::Drivers::Chrome
  protected def self.args : Array(String)
    ["no-sandbox", "headless", "disable-gpu"]
  end
end
