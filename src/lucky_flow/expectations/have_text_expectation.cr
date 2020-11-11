struct LuckyFlow::Expectations::HaveTextExpectation
  def initialize(@expected_value : String)
  end

  def match(element)
    element.text.includes? @expected_value
  end

  def failure_message(element)
    <<-MSG
    Expected element to have text: #{@expected_value}
                            actual: #{element.text}
    MSG
  end

  def negative_failure_message(element)
    "Expected element not to have text: #{@expected_value}"
  end
end
