class LuckyFlow::Drivers::HeadlessChrome < LuckyFlow::Drivers::Chrome
  protected def capabilities
    capabilities = super
    capabilities.args(["no-sandbox", "headless", "disable-gpu"])

    capabilities
  end
end
