module FormHelper
    def field_error(object, field)
      return unless object.errors[field].any?

      content_tag(:div, class: "text-sm text-red-600 mt-1") do
        object.errors[field].join(", ")
      end
    end
end
