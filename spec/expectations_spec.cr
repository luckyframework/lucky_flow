require "./spec_helper"

describe LuckyFlow::Expectations do
  it "gives a suggestion when a similar flow id is found" do
    element = LuckyFlow::Element.new(raw_selector: "@headning")

    visit_page_with "<span flow-id='heading'></span>"

    LuckyFlow::Expectations::BeOnPageExpectation.new
      .failure_message(element)
      .should contain("Did you mean")
  end

  it "does not give a suggestion when an element should not be found" do
    element = LuckyFlow::Element.new(raw_selector: "@heading")

    visit_page_with "<span flow-id='heading'></span>"

    LuckyFlow::Expectations::BeOnPageExpectation.new
      .negative_failure_message(element)
      .should_not contain("Did you mean")
  end
end
