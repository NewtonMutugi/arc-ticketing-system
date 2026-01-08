class Sidebar::UserProfileComponent < ViewComponent::Base
  def initialize(name:, email:, avatar_url: "")
    @name = name
    @email = email
    @avatar_url = avatar_url
  end
end
