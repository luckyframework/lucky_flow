{% if flag?("include-lucky") %}
require "./spec_helper"

# mock the Lucky classes so we don't have to include the entire framework
class Lucky::RouteHelper
  def initialize(@path : String); end
  def url
    [LuckyFlow.settings.base_uri, @path].join
  end
end
abstract class Lucky::Action; end
class Users::Index < Lucky::Action
  def self.route
    Lucky::RouteHelper.new("/users")
  end
end
class User; end

describe "Lucky Integrations" do
  it "can visit a URL with a Lucky::Action" do
    TestServer.route "/users", "<span flow-id='heading'>Users</span>"
    flow = LuckyFlow.new

    flow.visit(Users::Index)

    flow.el("@heading", text: "Users").should be_on_page
  end
end

{% end %}
