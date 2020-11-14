# LuckyFlow

[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fluckyframework.github.io%2Flucky_flow%2F)](https://luckyframework.github.io/lucky_flow)

LuckyFlow is a library for testing user flows in the browser. It is similar to
Ruby's Capybara.

![LuckyFlow example](https://user-images.githubusercontent.com/22394/40257158-1a2f30b8-5abb-11e8-90c2-94463638e65d.png)

## Installation in [Lucky](https://luckyframework.org) projects

LuckyFlow is already installed and configured. Check out the guides
to see how to use it: https://luckyframework.org/guides/browser-tests/

## Installation in other Crystal projects

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  lucky_flow:
    github: luckyframework/lucky_flow
```

Configure LuckyFlow in `spec/spec_helper.cr`:

```crystal
require "lucky_flow"

LuckyFlow.configure do |settings|
  # This is required
  settings.base_uri = "http://localhost:<port>"

  # Optional settings. Defaults are shown here
  settings.retry_delay = 10.milliseconds
  settings.stop_retrying_after = 1.second
  settings.screenshot_directory = "./tmp/screenshots"
  settings.browser_binary = "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
end

# Put this at the bottom of the file.
# If a required setting is missing, this will catch it.
Habitat.raise_if_missing_settings!
```

Then view the guides: https://luckyframework.org/guides/browser-tests/

You should be ready to go!

## Usage

> Note that you can only pass string paths to `visit` since only Lucky has
> route helpers described in the guide below. Example: `visit "/my-path"`

View guide at: https://luckyframework.org/guides/browser-tests/

## Contributing

1. Fork it ( https://github.com/luckyframework/lucky_flow/fork )
1. Create your feature branch (git checkout -b my-new-feature)
1. Install docker and docker-compose: https://docs.docker.com/compose/install/
1. Run `script/setup`
1. Make your changes
1. Run `script/test` to run the specs, build shards, and check formatting
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
