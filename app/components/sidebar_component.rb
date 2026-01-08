# frozen_string_literal: true

class SidebarComponent < ViewComponent::Base
  renders_many :items, types: {
    link: "Sidebar::ItemComponent",
    group: "Sidebar::GroupComponent"
  }

  renders_one :user_profile, "Sidebar::UserProfileComponent"

  def initialize(logo_text: "")
    @logo_text = logo_text
  end
end
