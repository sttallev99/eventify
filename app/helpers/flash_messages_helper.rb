module FlashMessagesHelper
  def flash_classes(type)
    case type.to_sym
    when :notice
      "bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative"
    when :alert
      "bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative"
    else
      "bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded relative"
    end
  end
end
