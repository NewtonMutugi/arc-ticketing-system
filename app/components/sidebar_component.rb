# frozen_string_literal: true

class SidebarComponent < ViewComponent::Base
  renders_many :items, types: {
    link: "Sidebar::ItemComponent",
    group: "Sidebar::GroupComponent"
  }

  renders_one :user_profile, "Sidebar::UserProfileComponent"
  # Allow any content in the footer
  renders_one :footer

  renders_one :header

  def initialize(logo_text: "")
    @logo_text = logo_text
  end
end
