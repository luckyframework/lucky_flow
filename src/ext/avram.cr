# If you have [Avram](https://github.com/luckyframework/avram)
# required, you can require this file for some additional helpers
module AvramLuckyFlowHelpers
  # Fill a form created by Lucky that uses an Avram::SaveOperation
  #
  # Note that Lucky and Avram are required to use this method
  #
  # ```
  # fill_form QuestionForm,
  #   title: "Hello there!",
  #   body: "Just wondering what day it is"
  # ```
  def fill_form(
    form : Avram::SaveOperation.class | Avram::Operation.class,
    **fields_and_values
  )
    fields_and_values.each do |name, value|
      element = field("#{form.param_key}:#{name}")
      if element.tag_name == "select"
        self.select(element, value.to_s)
      else
        self.fill(element, with: value)
      end
    end
  end
end

# ```
# require "lucky_flow/ext/avram"
# ```
class LuckyFlow
  include AvramLuckyFlowHelpers
end
