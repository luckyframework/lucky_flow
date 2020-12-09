require "./spec_helper"

describe LuckyFlow do
  it "can visit a URL" do
    TestServer.route "/home", "<span flow-id='heading'>Home</span>"
    flow = LuckyFlow.new

    flow.visit("/home")

    flow.el("@heading", text: "Home").should be_on_page
    flow.el("@heading").should have_text("Home")
    flow.should have_current_path("/home")
  end

  it "can visit URL with backdoor" do
    TestServer.route "/home?backdoor_user_id=abc123", "<span flow-id='heading'>Home</span>"
    user = User.new(id: "abc123")
    route_helper = Lucky::RouteHelper.new("http://localhost:3002/home")
    flow = LuckyFlow.new

    flow.visit(route_helper, as: user)

    flow.el("@heading", text: "Home").should be_on_page
  end

  it "can find element's text" do
    flow = visit_page_with "<span flow-id='heading'>Home</span>"

    flow.el("@heading").text.should eq "Home"
  end

  describe "helpful errors" do
    it "gives a suggestion if element not found" do
      flow = visit_page_with "<span flow-id='heading'>Home</span>"

      expect_raises LuckyFlow::ElementNotFoundError, "@heading" do
        flow.el("@harding").displayed?
      end
    end

    it "does not give a suggestion if not similar enough" do
      flow = visit_page_with "<span flow-id='heading'>Home</span>"

      expect_to_raise_without_suggestion do
        flow.el("@headboard").displayed?
      end
    end

    it "does not give recommendations for non flow-ids" do
      flow = visit_page_with "<span class='heading'>Home</span><span flow-id='headingg'></span>"

      expect_to_raise_without_suggestion do
        flow.el(".headinggg").displayed?
      end
    end

    it "does not give a suggestion if the flow id is correct but text is not" do
      flow = visit_page_with "<span flow-id='heading'>Home</span>"

      expect_to_raise_without_suggestion do
        flow.el("@heading", text: "Not Home").displayed?
      end
    end
  end

  it "can find a flow id" do
    flow = visit_page_with "<h1 flow-id='test-me'>Hello</h1>"
    flow.el("@test-me", text: "Hello").should be_on_page
    flow.el("@test-me", text: "Not here").should_not be_on_page
  end

  it "can find a generic CSS selector" do
    flow = visit_page_with "<h1 class='jumbotron'>Hello</h1>"
    flow.el(".jumbotron", text: "Hello").should be_on_page
    flow.el(".jumbotron", text: "Not here").should_not be_on_page
  end

  it "can fill in text" do
    flow = visit_page_with <<-HTML
      <input name="question:title"/>
      <input name="question:body"/>
    HTML
    flow.field("question:title").value.should eq ""
    flow.field("question:body").value.should eq ""

    flow.field("question:title").fill("Joe")
    flow.fill "question:body", with: "Sally"

    flow.field("question:title").value.should eq "Joe"
    flow.field("question:body").value.should eq "Sally"
  end

  it "clears existing text before filling" do
    flow = visit_page_with <<-HTML
      <input name="question:title"/>
      <input name="question:body"/>
    HTML

    flow.field("question:title").fill("Joe")
    flow.fill "question:body", with: "Sally"
    flow.field("question:title").fill("emacs")
    flow.fill "question:body", with: "vim"

    flow.field("question:title").value.should eq "emacs"
    flow.field("question:body").value.should eq "vim"
  end

  it "appends to existing text" do
    flow = visit_page_with <<-HTML
      <input name="question:title"/>
      <input name="question:body"/>
    HTML

    flow.field("question:title").fill("Joe")
    flow.fill "question:body", with: "Sally"
    flow.field("question:title").append(" (he/him)")
    flow.append "question:body", with: " (she/her)"

    flow.field("question:title").value.should eq "Joe (he/him)"
    flow.field("question:body").value.should eq "Sally (she/her)"
  end

  it "can get the value of an input" do
    flow = visit_page_with <<-HTML
      <input name="question:title" value="hello"/>
    HTML

    flow.field("question:title").value.should eq "hello"
  end

  it "can click elements" do
    TestServer.route "/target", "<h1>Target</h1>"
    flow = visit_page_with <<-HTML
      <h1>Home</h1>
      <a flow-id='target' href='/target'>Click Me</a>
    HTML
    flow.el("h1", text: "Home").should be_on_page

    flow.click("@target")

    flow.el("h1", text: "Target").should be_on_page
  end

  it "can open screenshots" do
    flow = LuckyFlow.new
    fake_process = FakeProcess
    time = Time.utc

    flow.open_screenshot(fake_process, time)

    fake_process.shell.should be_true
    fake_process.command.should eq "open ./tmp/screenshots/#{time.to_unix}.png"
  end

  it "can open fullsize screenshots" do
    flow = LuckyFlow.new
    fake_process = FakeProcess
    time = Time.utc

    flow.open_screenshot(fake_process, time, fullsize: true)

    fake_process.shell.should be_true
    fake_process.command.should eq "open ./tmp/screenshots/#{time.to_unix}.png"
  end

  it "can reset the session" do
    flow = visit_page_with <<-HTML
      <h1>Title</h1>
    HTML
    flow.session.cookie_manager.add_cookie("hello", "world")
    flow.session.cookie_manager.get_cookie("hello").value.should eq "world"

    LuckyFlow.reset

    expect_raises Selenium::Error do
      flow.session.cookie_manager.get_cookie("hello").value
    end
  end

  it "can accept and dismiss alerts" do
    flow = visit_page_with <<-HTML
      <button onclick="createAlert()" flow-id="button" data-count="0">Click Me - 0</button>
      <script>
      function createAlert() {
        alert("Are you sure?");
        const button = document.querySelector("[flow-id='button']");
        button.innerText = 'Click Me - ' + (++button.dataset.count);
      }
      </script>
    HTML

    flow.click("@button")
    flow.accept_alert
    flow.el("@button", text: "Click Me - 1").should be_on_page
    flow.click("@button")
    flow.dismiss_alert
    flow.el("@button", text: "Click Me - 2").should be_on_page
  end

  it "can choose option in select input" do
    flow = visit_page_with <<-HTML
      <select name="cars" id="cars">
        <option value="ford">Ford</option>
        <option value="honda">Honda</option>
        <option value="tesla">Tesla</option>
      </select>
    HTML

    flow.select("cars", value: "honda")
    flow.el("#cars").value.should eq "honda"
    flow.select("cars", value: "ford")
    flow.el("#cars").value.should eq "ford"
  end

  it "can choose options in multi select input" do
    flow = visit_page_with <<-HTML
      <select name="cars" id="cars" multiple>
        <option value="ford">Ford</option>
        <option value="honda">Honda</option>
        <option value="tesla">Tesla</option>
        <option value="toyota">Toyota</option>
      </select>
    HTML

    flow.select("cars", value: ["honda", "toyota"])
    flow.el("option[value='ford']").selected?.should be_false
    flow.el("option[value='honda']").selected?.should be_true
    flow.el("option[value='tesla']").selected?.should be_false
    flow.el("option[value='toyota']").selected?.should be_true
  end

  it "raises error if attempting to select multiple options when not multi select" do
    flow = visit_page_with <<-HTML
      <select name="cars" id="cars">
        <option value="ford">Ford</option>
        <option value="honda">Honda</option>
        <option value="tesla">Tesla</option>
        <option value="toyota">Toyota</option>
      </select>
    HTML

    expect_raises(LuckyFlow::InvalidOperationError) do
      flow.select("cars", value: ["honda", "toyota"])
    end
  end

  it "can hover over an element" do
    flow = visit_page_with <<-HTML
      <style>
        #hidden {
          display: none;
        }
        #hoverable:hover + #hidden {
          display: block;
        }
      </style>
      <p id="hoverable">Hello, world!</p>
      <p id="hidden">Now you see me!</p>
    HTML

    flow.el("#hidden").displayed?.should be_false
    flow.el("#hoverable").hover
    flow.el("#hidden").displayed?.should be_true
  end
end

private class FakeProcess
  class_property command : String?
  class_property shell : Bool?

  def initialize(command, shell)
    @@command = command
    @@shell = shell
  end

  def self.find_executable(string)
    "/fake_path_to_executable"
  end
end

private def expect_to_raise_without_suggestion
  error = expect_raises LuckyFlow::ElementNotFoundError do
    yield
  end
  error.to_s.should_not contain("Did you mean")
end
