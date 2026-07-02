class OrderPolicy < ApplicationPolicy
  def approve?
    update?
  end

  def resend_confirmation_email?
    update?
  end

  def reject_payment?
    update?
  end
end
