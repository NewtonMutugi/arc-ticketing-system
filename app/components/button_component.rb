# frozen_string_literal: true



class ButtonComponent < ViewComponent::Base
  INTENTS = {
    primary: {
      wrapper: "text-white focus:ring-red-600",
      border: "border-red-600",
      forground: "border-red-600 bg-red-600"
    },
    secondary: {
      wrapper: "text-red-600 focus:ring-red-600",
      border: "border-current",
      forground: "border-current bg-white"
    }
  }
  def initialize(intent: :primary, href: nil, type: "button", **system_arguments)
    @href = href
    @type = type
    @intent_data = INTENTS[intent] || INTENTS[:primary]
    @system_arguments = system_arguments
  end

  def render_as_link?
    @href.present?
  end

  def wrapper_classes
    base = "group relative inline-block text-sm font-medium focus:outline-none focus:ring-3"
    class_names(base, @intent_data[:wrapper], @system_arguments[:class])
  end

  def background_border_classes
    class_names("absolute inset-0 border", @intent_data[:border])
  end

  def foreground_classes
    base = "block px-12 py-3 transition-transform group-hover:-translate-x-1 group-hover:-translate-y-1 border cursor-pointer"
    class_names(base, @intent_data[:foreground])
  end
end
