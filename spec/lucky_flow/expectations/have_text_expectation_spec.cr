require "../../spec_helper"

module LuckyFlow::Expectations
  describe HaveTextExpectation do
    describe "#match" do
      it "returns true if element has text" do
        element = LuckyFlow::Element.new(raw_selector: "@heading")

        visit_page_with "<span flow-id='heading'>Hello, World!</span>"

        expectation = HaveTextExpectation.new(expected_value: "Hello, World!")

        expectation.match(element).should be_true
      end

      it "returns false if element does not have text" do
        element = LuckyFlow::Element.new(raw_selector: "@heading")

        visit_page_with "<span flow-id='heading'>Hello, World!</span>"

        expectation = HaveTextExpectation.new(expected_value: "Hello, Steve!")

        expectation.match(element).should be_false
      end

      it "returns true if element contains text" do
        element = LuckyFlow::Element.new(raw_selector: "@container")

        visit_page_with <<-HTML
          <div flow-id="container">
            <h1>Hello, World!</h1>
            <span>Welcome to the subheading</span>
          </div>
        HTML

        expectation = HaveTextExpectation.new(expected_value: "Hello, World!")

        expectation.match(element).should be_true
      end
    end

    describe "#failure_message" do
      it "returns actual text found on element" do
        element = LuckyFlow::Element.new(raw_selector: "@heading")

        visit_page_with "<span flow-id='heading'>Hello, World!</span>"

        expectation = HaveTextExpectation.new(expected_value: "Hello, Steve!")
        message = expectation.failure_message(element)

        message.should contain("Expected element to have text: Hello, Steve!")
        message.should contain("actual: Hello, World!")
      end
    end

    describe "#negative_failure_message" do
      it "returns actual text found on element" do
        element = LuckyFlow::Element.new(raw_selector: "@heading")

        visit_page_with "<span flow-id='heading'>Hello, World!</span>"

        expectation = HaveTextExpectation.new(expected_value: "Hello, World!")
        message = expectation.negative_failure_message(element)

        message.should contain("Expected element not to have text: Hello, World!")
      end
    end
  end
end
