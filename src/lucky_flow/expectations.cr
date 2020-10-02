require "./expectations/**"

class LuckyFlow
  module Expectations
    private def be_on_page
      BeOnPageExpectation.new
    end

    private def have_text(expected_text)
      HaveTextExpectation.new(expected_text)
    end

    private def have_current_path(expected_path : String)
      HaveCurrentPathExpectation.new(expected_path)
    end

    private def have_current_path(action : Lucky::Action.class)
      have_current_path(action.route)
    end

    private def have_current_path(route_helper : Lucky::RouteHelper)
      HaveCurrentPathExpectation.new(route_helper.path)
    end
  end
end
