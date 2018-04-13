# Returns selector or transforms it into a flow-id selector
#
# Example:
#
#   Selector.new(".some-class").parse # => ".some-class"
#   Selector.new("@new-comment-button").parse # => "[flow-id='new-comment-button']"
class LuckyFlow::Selector
  private getter raw_selector

  def initialize(@raw_selector : String)
  end

  def parse
    if should_select_flow_id?
      flow_id_selector
    else
      raw_selector
    end
  end

  private def should_select_flow_id?
    raw_selector.starts_with?("@")
  end

  private def flow_id_selector
    stripped_selector = raw_selector.gsub("@", "")
    "[flow-id='#{stripped_selector}']"
  end
end
