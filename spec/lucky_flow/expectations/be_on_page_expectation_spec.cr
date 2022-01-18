require "../../spec_helper"

module LuckyFlow::Expectations
  describe BeOnPageExpectation do
    it "gives a suggestion when a similar flow id is found" do
      visit_page_with "<span flow-id='heading'></span>"

      BeOnPageExpectation.new("@headning", text: nil)
        .failure_message(LuckyFlow.new)
        .should contain("Did you mean")
    end

    it "does not give a suggestion when an element should not be found" do
      visit_page_with "<span flow-id='heading'></span>"

      BeOnPageExpectation.new("@heading", text: nil)
        .negative_failure_message(LuckyFlow.new)
        .should_not contain("Did you mean")
    end
  end
end
