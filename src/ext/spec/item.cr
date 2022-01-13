module Spec
  module Item
    def all_tags : Set(String)
      all_tags = tags || Set(String).new
      temp = parent
      if temp.is_a?(Spec::Item)
        all_tags += temp.all_tags
      end
      all_tags
    end
  end
end
