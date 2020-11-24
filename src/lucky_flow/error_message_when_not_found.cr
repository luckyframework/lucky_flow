class LuckyFlow::ErrorMessageWhenNotFound
  private getter selector, negate

  def self.build(*args, **named_args)
    new(*args, **named_args).build
  end

  def initialize(
    @selector : String,
    @inner_text : String?,
    @negate : Bool = false
  )
  end

  def build
    String.build do |message|
      message << "Expected "
      message << "not " if negate
      message << "to find element on page, but it was "
      message << "not " unless negate
      message << "found."
      message << "\n\n  ▸ looking for: #{selector}"

      if !inner_text.empty?
        message << "\n  ▸ with text: #{inner_text}"
      end

      if similar_flow_id && inner_text.empty? && !negate
        message << "\n\n"
        message << " Did you mean..."
        message << "\n\n  ▸ "
        message << "'@#{similar_flow_id}'\n"
      end
    end
  end

  def inner_text
    (@inner_text || "")
  end

  private def similar_flow_id : String?
    if only_looking_for_flow_id?
      Levenshtein::Finder.find selector_with_deleted_flow_id_attr, all_flow_ids, tolerance: 5
    end
  end

  private def selector_with_deleted_flow_id_attr
    selector.gsub(%([flow-id='), "").gsub(%('']), "")
  end

  private def all_flow_ids : Array(String)
    session.find_elements(:css, "[flow-id]")
      .map(&.attribute("flow-id"))
      .compact
      .uniq
  end

  private def only_looking_for_flow_id? : Bool
    selector.starts_with?("[flow-id") && !not_using_any_other_selector?
  end

  private def not_using_any_other_selector? : Bool
    selector.includes?(" ")
  end

  private def session
    LuckyFlow.session
  end
end
