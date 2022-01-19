require "../../spec_helper"

module LuckyFlow::Expectations
  describe HaveElementExpectation do
    it "gives a suggestion when a similar flow id is found" do
      visit_page_with "<span flow-id='heading'></span>"

      HaveElementExpectation.new("@headning", text: nil, visible: true)
        .failure_message(LuckyFlow.new)
        .should contain("Did you mean")
    end

    it "does not give a suggestion when an element should not be found" do
      visit_page_with "<span flow-id='heading'></span>"

      HaveElementExpectation.new("@heading", text: nil, visible: true)
        .negative_failure_message(LuckyFlow.new)
        .should_not contain("Did you mean")
    end
  end
end
