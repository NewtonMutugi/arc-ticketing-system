# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  def initialize(name:, label:, id: nil, type: "text", placeholder: " ", value: nil, required: true, autocomplete: "off", options: nil, accept: nil, className: "", rows: nil)
    @name = name
    @label = label
    @id = id || name
    @type = type == "datetime" ? "datetime-local" : type
    @placeholder = placeholder
    @value = value
    @required = required
    @autocomplete = autocomplete
    @options = options
    @accept = accept
    @class_name = className
    @rows = rows
  end

  def input_classes
    base = "peer mt-0.5 w-full rounded border-gray-300 px-3 py-3 shadow-sm placeholder-transparent focus:border-red-600 focus:outline-none focus:ring-red-600 sm:text-sm"

    "#{@class_name} #{base}"
  end

  def label_classes
    base = "pointer-events-none absolute start-3 top-0 -translate-y-1/2 bg-white px-0.5 text-xs text-gray-700 transition-all peer-placeholder-shown:top-1/2 peer-placeholder-shown:text-sm peer-focus:top-0 peer-focus:text-xs"

    return "block text-sm font-medium text-gray-700 mb-1" if @type == "file"

    base
  end

  def wrapper_classes
    return "block my-2" if @type == "file"
    "relative block py-2 my-2"
  end
end
