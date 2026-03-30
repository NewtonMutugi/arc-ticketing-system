class Admin::TicketsController < Admin::BaseController
  layout "event_dashboard"
  before_action :set_event

  def index
    @tickets = @event.tickets
  end

  def show
  end

  def destroy
    @ticket = @event.tickets.find(params[:id])
    if @ticket.destroy
      respond_to do |format|
        format.html { redirect_to admin_event_tickets_path(@event), notice: "Ticket deleted successfully." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@ticket),
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Success", body: "Ticket deleted successfully." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_event_tickets_path(@event), alert: "Could not delete ticket." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :error, title: "Error", body: "Could not delete ticket." })
        end
      end
    end
  rescue ActiveRecord::InvalidForeignKey
    respond_to do |format|
      format.html { redirect_to admin_event_tickets_path(@event), alert: "Cannot delete this ticket because it has orders attached to it." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :error, title: "Deletion Failed", body: "Cannot delete this ticket because it has orders attached to it." })
      end
    end
  end

  def new
    @ticket = @event.tickets.new
  end

  def create
    @ticket = @event.tickets.new(ticket_params)
    @ticket.created_by_user_id = Current.user.id
    if @ticket.save
      # redirect_to admin_event_tickets_path(@event), notice: "Ticket created successfully."
      respond_to do |format|
        format.html { redirect_to admin_event_tickets_path(@event), notice: "Ticket created successfully." }

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend(@ticket, partial: "admin/tickets/ticket", locals: { ticket: @ticket, event: @event }),
            turbo_stream.update("modal", ""),
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Success", body: "Ticket created successfully." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @ticket = @event.tickets.find(params[:id])
  end

  def update
    @ticket = @event.tickets.find(params[:id])
    if @ticket.update(ticket_params)

      respond_to do |format|
        format.html { redirect_to admin_event_tickets_path(@event), notice: "Ticket updated successfully." }

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@ticket, partial: "admin/tickets/ticket", locals: { ticket: @ticket, event: @event }),
            turbo_stream.update("modal", ""),
            turbo_stream.append("flash-toasts", partial: "shared/flash_toast", locals: { type: :success, title: "Success", body: "Ticket updated successfully." })
          ]
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_events_path, alert: "Event not found"
  end

  def ticket_params
    params.require(:ticket).permit(:title, :price, :quantity, :description, :start_sale_date, :end_sale_date, :min_ticket, :max_ticket, :group_ticket_count, :status, :benefits)
  end
end
