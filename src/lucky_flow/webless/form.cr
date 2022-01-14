class LuckyFlow::Webless::Form
  ALL_FORM_FIELDS              = ".//*[self::input | self::select | self::textarea | self::button][not(./@form)][not(./@disabled)]"
  ALL_FORM_FIELDS_WITH_FORM_ID = ".//*[self::input | self::select | self::textarea | self::button][not(./@form)][not(./@disabled)] | //*[self::input | self::select | self::textarea | self::button][(./@form = '%s')][not(./@disabled)]"
  private getter form_node : HTML5::Node
  private getter submit_node : HTML5::Node

  def initialize(@form_node, @submit_node)
  end

  def submit(driver : LuckyFlow::Webless::Driver)
    form_field_xpath = if (id_attr = @form_node["id"]?) && !id_attr.val.blank?
                         ALL_FORM_FIELDS_WITH_FORM_ID % id_attr.val
                       else
                         ALL_FORM_FIELDS
                       end
    form_field_nodes = @form_node.xpath_nodes(form_field_xpath)
    form_field_nodes.reject! { |node| submitter?(node) && node != submit_node }

    form_values = form_field_nodes.compact_map do |form_field_node|
      case form_field_node.data
      when "input"
        parse_input_field(form_field_node)
      when "textarea"
        parse_textarea_field(form_field_node)
      when "select"
        parse_select_field(form_field_node)
      end
    end.to_h

    request_method = @form_node["method"]?.try(&.val) == "post" ? :post : :get
    request_path = @submit_node["formaction"]?.try(&.val.presence) || @form_node["action"].val
    request = ::Webless::RequestBuilder.new
      .method(request_method)
      .path(request_path)
      .form(form_values, multipart?)
      .build

    driver.submit(request)
  end

  private def submitter?(node : HTML5::Node) : Bool
    type = node["type"]?.try &.val
    tag_name = node.data
    (tag_name == "input" && type == "submit") || (tag_name == "button" && (type.nil? || type == "submit"))
  end

  private def parse_input_field(input_field : HTML5::Node) : Tuple(String, String | File)?
    name = input_field["name"]?.try(&.val.presence)
    value = input_field["value"]?.try(&.val)
    return if name.nil?

    value = case input_field["type"]?.try(&.val.presence)
            when "checkbox"
              return unless input_field["checked"]?

              value || "on"
            when "radio"
              return unless input_field["checked"]?

              value.to_s
            when "file"
              if multipart?
                val = value.presence
                return if val.nil?

                File.new(val)
              else
                File.basename(value.to_s)
              end
            else
              value.to_s
            end

    {name, value}
  end

  private def parse_textarea_field(textarea : HTML5::Node) : Tuple(String, String)?
    name = textarea["name"]?.try(&.val.presence)
    value = textarea["value"]?.try(&.val.presence) || textarea.first_child.try &.data.presence
    return if name.nil? || value.nil?

    {name, value}
  end

  private def parse_select_field(select_field : HTML5::Node) : Tuple(String, String | Array(String))?
    name = select_field["name"]?.try(&.val.presence)
    return if name.nil?

    if select_field["multiple"]?
      values = select_field.xpath_nodes(".//option[@selected]")
        .map { |option| option["value"]?.try(&.val) || option.first_child.try(&.data) }
        .map(&.to_s)
      {name, values}
    else
      option = select_field.xpath(".//option[@selected]") || select_field.xpath(".//option")
      return if option.nil?

      value = option["value"]?.try(&.val) || option.first_child.try(&.data)
      {name, value.to_s}
    end
  end

  private def multipart? : Bool
    form_node["enctype"]?.try(&.val) == "multipart/form-data"
  end
end
