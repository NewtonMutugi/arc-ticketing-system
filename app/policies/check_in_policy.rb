class CheckInPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def destroy?
    !user.volunteer?
  end
end
