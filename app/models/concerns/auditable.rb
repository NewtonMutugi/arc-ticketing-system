module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy
  end

  class_methods do
    def track_audit_on(*attributes)
      @track_audit_attributes = attributes

      [ :create, :update, :destroy ].each do |action|
        send("after_#{action}", :log_audit_action)
      end
    end

    def tracked_audit_attributes
      @track_audit_attributes || []
    end
  end

  private

  def log_audit_action
    user = Current.user || User.first
    return unless user

    action = case
    when destroyed? then :deleted
    when created? then :created
    else :updated
    end

    changes = if action == :updated
                self.saved_changes.slice(*self.class.tracked_audit_attributes)
    elsif action == :deleted
                attribute_changes_from_destroyed
    else
                {}
    end

    AuditLog.log_action(
      user,
      action,
      self,
      changes: changes.presence,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  def attribute_changes_from_destroyed
    # For destroyed objects, capture the old values
    self.class.tracked_audit_attributes.each_with_object({}) do |attr, hash|
      hash[attr] = attribute_was(attr)
    end
  end
end
