require "./expectations/**"

class LuckyFlow
  module Expectations
    private def be_on_page
      BeOnPageExpectation.new
    end
  end
end
