require "./expectations/**"

class LuckyFlow
  module Expectations
    private def be_on_page
      BeOnPageExpectation.new
    end

    private def have_text(expected_text)
      HaveTextExpectation.new(expected_text)
    end
  end
end
