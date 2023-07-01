require "./spec_helper"

describe LuckyFlow do
  it "can visit a URL" do
    TestServer.route "/home", "<span flow-id='heading'>Home</span>"
    flow = LuckyFlow.new

    flow.visit("/home")

    flow.should have_element("@heading", text: "Home")
    flow.el("@heading").should have_text("Home")
    flow.should have_current_path("/home")
  end

  it "can visit URL with backdoor" do
    TestServer.route "/home?backdoor_user_id=abc123", "<span flow-id='heading'>Home</span>"
    user = User.new(id: "abc123")
    route_helper = Lucky::RouteHelper.new("http://localhost:3002/home")
    flow = LuckyFlow.new

    flow.visit(route_helper, as: user)

    flow.should have_element("@heading", text: "Home")
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
    flow.should have_element("@test-me", text: "Hello")
    flow.should_not have_element("@test-me", text: "Not here")
  end

  it "can find a generic CSS selector" do
    flow = visit_page_with "<h1 class='jumbotron'>Hello</h1>"
    flow.should have_element(".jumbotron", text: "Hello")
    flow.should_not have_element(".jumbotron", text: "Not here")
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

  it "can fill in textarea" do
    flow = visit_page_with <<-HTML
      <textarea name="question:text"></textarea>
    HTML
    flow.field("question:text").value.should eq ""

    flow.field("question:text").fill("What's up?")

    flow.field("question:text").value.should eq "What's up?"
  end

  it "can select option" do
    flow = visit_page_with <<-HTML
    <select name="options">
      <option value="a">A</option>
      <option value="b" flow-id="option-b">B</option>
      <option value="c" flow-id="option-c" selected>C</option>
    </select>
    HTML

    flow.select("options", "b")
    flow.el("@option-b").selected?.should be_true
    flow.el("@option-c").selected?.should be_false
  end

  it "can check checkbox" do
    flow = visit_page_with <<-HTML
    <input name="agree" type="checkbox" flow-id="agree">
    HTML

    flow.click("@agree")
    flow.el("@agree").checked?.should be_true
    flow.click("@agree")
    flow.el("@agree").checked?.should be_false
  end

  it "can submit form" do
    handle_route("/foo") do |context|
      <<-HTML
        <p flow-id="result">#{context.request.body.as(IO).gets_to_end}</p>
      HTML
    end

    flow = visit_page_with <<-HTML
      <form action="/foo" method="post">
        <input name="secret" value="abc" type="hidden">
        <input name="car" value="ford" type="radio" checked>
        <input name="othercar" value="toyota" type="radio">
        <input name="horns" type="checkbox" checked>
        <input name="scales" type="checkbox">
        <textarea name="textarea">TEXT HERE</textarea>
        <select name="options">
          <option value="a">A</option>
          <option value="b" selected>B</option>
          <option value="c">C</option>
        </select>
        <select name="multiple" multiple>
          <option value="a">A</option>
          <option value="b" selected>B</option>
          <option value="c" selected>C</option>
        </select>
        <button flow-id="submit" type="submit">Submit</button>
      </form>
    HTML

    flow.el("@submit").click
    flow.should have_element("@result", text: "secret=abc")
    flow.should have_element("@result", text: "car=ford")
    flow.should_not have_element("@result", text: "othercar=toyota")
    flow.should have_element("@result", text: "horns=on")
    flow.should_not have_element("@result", text: "scales")
    flow.should have_element("@result", text: "textarea=TEXT+HERE")
    flow.should have_element("@result", text: "options=b")
    flow.should have_element("@result", text: "multiple=b")
    flow.should have_element("@result", text: "multiple=c")
  end

  it "submits dates appropriately", tags: "headless_chrome" do
    handle_route("/foo") do |context|
      <<-HTML
        <p flow-id="result">#{context.request.body.as(IO).gets_to_end}</p>
      HTML
    end

    flow = visit_page_with <<-HTML
      <form action="/foo" method="post">
        <input name="custom_date" type="date">
        <button flow-id="submit" type="submit">Submit</button>
      </form>
    HTML

    flow.fill "custom_date", with: Time.utc(2016, 2, 15)
    flow.el("@submit").click
    flow.should have_element("@result", text: "custom_date=2016-02-15")
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
    flow.should have_element("h1", text: "Home")

    flow.click("@target")

    flow.should have_element("h1", text: "Target")
  end

  it "can open screenshots", tags: "headless_chrome" do
    flow = LuckyFlow.new
    fake_process = FakeProcess
    time = Time.utc

    flow.open_screenshot(fake_process, time)

    fake_process.shell.should be_true
    fake_process.command.should eq "open ./tmp/screenshots/#{time.to_unix}.png"
  end

  it "can open fullsize screenshots", tags: "headless_chrome" do
    flow = LuckyFlow.new
    fake_process = FakeProcess
    time = Time.utc

    flow.open_screenshot(fake_process, time, fullsize: true)

    fake_process.shell.should be_true
    fake_process.command.should eq "open ./tmp/screenshots/#{time.to_unix}.png"
  end

  it "can reset the session", tags: "headless_chrome" do
    flow = visit_page_with <<-HTML
      <h1>Title</h1>
    HTML
    flow.driver.add_cookie("hello", "world")
    flow.driver.get_cookie("hello").should eq "world"

    LuckyFlow.reset

    expect_raises Selenium::Error do
      flow.driver.get_cookie("hello")
    end
  end

  it "can accept and dismiss alerts", tags: "headless_chrome" do
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
    flow.should have_element("@button", text: "Click Me - 1")
    flow.click("@button")
    flow.dismiss_alert
    flow.should have_element("@button", text: "Click Me - 2")
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

  it "can hover over an element", tags: "headless_chrome" do
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

  it "handles redirects" do
    handle_route("/foo") do |context|
      context.response.headers.add "Location", "/bar"
      context.response.status_code = 302
      "foo"
    end

    handle_route("/bar") do |_context|
      <<-HTML
        <span flow-id="bar">bar</span>
      HTML
    end

    flow = visit_page_with <<-HTML
      <a href="/foo" flow-id="link">Foo</a>
    HTML

    flow.click("@link")

    flow.should have_element("@bar", text: "bar")
  end

  it "handles multiple redirects" do
    handle_route("/foo") do |context|
      context.response.headers.add "Location", "/bar"
      context.response.status_code = 302
      "foo"
    end

    handle_route("/bar") do |context|
      context.response.headers.add "Location", "/bazz"
      context.response.status_code = 302
      "foo"
    end

    handle_route("/bazz") do |_context|
      <<-HTML
        <span flow-id="bazz">bazz</span>
      HTML
    end

    flow = visit_page_with <<-HTML
      <a href="/foo" flow-id="link">Foo</a>
    HTML

    flow.click("@link")

    flow.should have_element("@bazz", text: "bazz")
  end

  it "raises error on infinite redirect", tags: "webless" do
    handle_route("/foo") do |context|
      context.response.headers.add "Location", "/bar"
      context.response.status_code = 302
      "foo"
    end

    handle_route("/bar") do |context|
      context.response.headers.add "Location", "/foo"
      context.response.status_code = 302
      "foo"
    end

    flow = visit_page_with <<-HTML
      <a href="/foo" flow-id="link">Foo</a>
    HTML

    expect_raises(LuckyFlow::InfiniteRedirectError) { flow.click("@link") }
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

private def expect_to_raise_without_suggestion(&)
  error = expect_raises LuckyFlow::ElementNotFoundError do
    yield
  end
  error.to_s.should_not contain("Did you mean")
end
