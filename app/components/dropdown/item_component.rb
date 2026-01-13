class Dropdown::ItemComponent < ViewComponent::Base
  def initialize(title:, href:, icon: nil, **html_attrs)
    @title = title
    @href = href
    @icon = icon
    @html_attrs = html_attrs
  end

  def call
    @html_attrs[:class] = class_names(
      "group flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:text-gray-900 w-full text-left",
      @html_attrs[:class]
    )
    link_to @href, @html_attrs  do
        safe_join([
          render_icon,
          tag.span(@title, class: "ml-3")
        ])
    end
  end

  private

  def render_icon
    return unless @icon
    tag.i(class: "#{@icon} w-5 text-center text-gray-400 group-hover:text-gray-500")
  end
end
