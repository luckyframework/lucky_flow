# If you have [Authentic](https://github.com/luckyframework/authentic)
# required, you can require this file for some additional helpers
module AuthenticLuckyFlowHelpers
  def visit(action : Lucky::Action.class, as user : User)
    visit(action.route, as: user)
  end

  def visit(route_helper : Lucky::RouteHelper, as user : User)
    url = route_helper.url
    uri = URI.parse(url)
    if uri.query
      url += "&backdoor_user_id=#{user.id}"
    elsif uri.query.nil?
      url += "?backdoor_user_id=#{user.id}"
    end
    driver.visit(url)
  end
end

# ```
# require "lucky_flow/ext/authentic"
# ```
class LuckyFlow
  include AuthenticLuckyFlowHelpers
end
