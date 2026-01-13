# frozen_string_literal: true

class DropdownComponent < ViewComponent::Base
  # Renders many since a menu has many items
  renders_many :items, "Dropdown::ItemComponent"

  # Renders one trigger (the profile pic or button)
  renders_one :trigger

  def initialize(align: :right)
    @align = align
  end

  def alignment_class
    @align == :right ? "right-0" : "left-0"
  end
end
