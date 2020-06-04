struct LuckyFlow::Expectations::BeOnPageExpectation
  def match(element : LuckyFlow::Element) : Bool
    element.displayed?
  rescue LuckyFlow::ElementNotFoundError
    false
  end

  def failure_message(element)
    LuckyFlow::ErrorMessageWhenNotFound.build(
      element.selector,
      element.inner_text
    )
  end

  def negative_failure_message(element)
    LuckyFlow::ErrorMessageWhenNotFound.build(
      element.selector,
      element.inner_text,
      negate: true
    )
  end
end
