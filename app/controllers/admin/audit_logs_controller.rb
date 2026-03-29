class Admin::AuditLogsController < Admin::BaseController
  def index
    @query = AuditLog.includes(:user, :auditable).order(created_at: :desc)

    # Filter by user if provided
    if params[:user_id].present?
      @query = @query.where(user_id: params[:user_id])
    end

    # Filter by action if provided
    if params[:action].present?
      @query = @query.where(action: params[:action])
    end

    # Filter by model type if provided
    if params[:auditable_type].present?
      @query = @query.where(auditable_type: params[:auditable_type])
    end

    # Filter by date range if provided
    if params[:start_date].present?
      @query = @query.where("audit_logs.created_at >= ?", Date.parse(params[:start_date]).beginning_of_day)
    end

    if params[:end_date].present?
      @query = @query.where("audit_logs.created_at <= ?", Date.parse(params[:end_date]).end_of_day)
    end

    @pagy, @audit_logs = pagy(@query)
    @users = User.where(admin: true).order(:first_name)
    @actions = AuditLog.actions.keys
    @auditable_types = AuditLog.pluck(:auditable_type).uniq.sort
  end

  def show
    @audit_log = AuditLog.find(params[:id])
  end
end
