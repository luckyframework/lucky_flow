struct LuckyFlow::Expectations::HaveCurrentPathExpectation
  def initialize(@expected_path : String)
  end

  def match(flow : LuckyFlow) : Bool
    flow.current_path == @expected_path
  end

  def failure_message(flow)
    <<-MSG
    Expected current path to be: #{@expected_path}
                         actual: #{flow.current_path}
    MSG
  end

  def negative_failure_message(_flow)
    "Expected current path not to be: #{@expected_path}"
  end
end
