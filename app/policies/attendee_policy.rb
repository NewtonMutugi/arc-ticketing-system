class AttendeePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    !user.volunteer?
  end

  def update?
    !user.volunteer?
  end

  def destroy?
    !user.volunteer?
  end

  def resend_ticket?
    !user.volunteer?
  end
end
