# If you have [Lucky](https://github.com/luckyframework/lucky)
# required, you can require this file for some additional helpers
module LuckyActionLuckyFlowHelpers
  def visit(action : Lucky::Action.class)
    visit(action.route)
  end

  def visit(route_helper : Lucky::RouteHelper)
    url = route_helper.url
    driver.visit(url)
  end
end

# ```
# require "lucky_flow/ext/lucky"
# ```
class LuckyFlow
  include LuckyActionLuckyFlowHelpers
end
