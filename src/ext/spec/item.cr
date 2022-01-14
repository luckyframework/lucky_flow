module Spec
  module Item
    # :nodoc:
    def _lucky_flow_all_tags : Set(String)
      all_tags = tags || Set(String).new
      temp = parent
      if temp.is_a?(Spec::Item)
        all_tags += temp._lucky_flow_all_tags
      end
      all_tags
    end
  end
end
