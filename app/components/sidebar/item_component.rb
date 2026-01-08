class Sidebar::ItemComponent < ViewComponent::Base
  def initialize(title:, href:)
    @title = title
    @href = href
  end

  def call
    link_to @title, @href, class: classes
  end

  private

  def classes
    base = "block rounded-lg px-4 py-2 text-sm font-medium"

    # Logic: If current page matches href, use Active styles, else Inactive
    if active?
      "#{base} bg-gray-100 text-gray-700"
    else
      "#{base} text-gray-500 hover:bg-gray-100 hover:text-gray-700"
    end
  end

  def active?
    # Simple check. You can make this smarter (e.g., regex) if needed.
    request.path == @href
  end
end
