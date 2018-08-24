class LuckyFlow
  # These are helpers that are specific to Lucky applications
  # 
  module LuckyHelpers
    def visit(action : Lucky::Action.class, as user : User? = nil)
      visit(action.route, as: user)
    end

    def visit(route_helper : Lucky::RouteHelper, as user : User? = nil)
      url = route_helper.url
      uri = URI.parse(url)
      if uri.query && user
        url += "&backdoor_user_id=#{user.id}"
      elsif uri.query.nil? && user
        url += "?backdoor_user_id=#{user.id}"
      end
      session.url = url
    end
  
    # Fill a form created by Lucky that uses a LuckyRecord::Form
    #
    # Note that Lucky and LuckyRecord are required to use this method
    #
    # ```
    # fill_form QuestionForm,
    #   title: "Hello there!",
    #   body: "Just wondering what day it is"
    # ```
    def fill_form(
      form : LuckyRecord::Form.class | LuckyRecord::VirtualForm.class,
      **fields_and_values
    )
      fields_and_values.each do |name, value|
        fill "#{form.new.form_name}:#{name}", with: value
      end
    end
  end
end

