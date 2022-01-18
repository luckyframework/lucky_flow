struct LuckyFlow::Expectations::BeOnPageExpectation
  @css_selector : String

  def initialize(css_selector : String, @text : String?)
    @css_selector = Selector.new(css_selector).parse
  end

  def match(flow : LuckyFlow) : Bool
    element = if text = @text
                flow.el(@css_selector, text)
              else
                flow.el(@css_selector)
              end

    element.displayed?
  rescue LuckyFlow::ElementNotFoundError
    false
  end

  def failure_message(flow : LuckyFlow)
    LuckyFlow::ErrorMessageWhenNotFound.build(
      flow.driver,
      @css_selector,
      @text
    )
  end

  def negative_failure_message(flow : LuckyFlow)
    LuckyFlow::ErrorMessageWhenNotFound.build(
      flow.driver,
      @css_selector,
      @text,
      negate: true
    )
  end
end
