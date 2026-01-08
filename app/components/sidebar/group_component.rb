class Sidebar::GroupComponent < ViewComponent::Base
  # The group renders inner items (links)
  renders_many :items, "Sidebar::ItemComponent"

  def initialize(title:)
    @title = title
  end

  # Check if any child link is currently active to auto-open the group
  def open?
    items.any? { |item| request.path == item.instance_variable_get(:@href) }
  end
end
