# frozen_string_literal: true

class InputComponent < ViewComponent::Base
  def initialize(name:, label:, id: nil, type: "text", placeholder: " ", value: nil, required: true, autocomplete: "")
    @name = name
    @label = label
    @id = id || name
    @type = type
    @placeholder = placeholder
    @value = value
    @required = required,
    @autocomplete = autocomplete
  end
end
