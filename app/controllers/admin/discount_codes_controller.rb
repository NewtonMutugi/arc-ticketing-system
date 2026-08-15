module Admin
  class DiscountCodesController < BaseController
    layout "event_dashboard"
    before_action :set_event
    before_action :set_discount_code, only: %i[edit update destroy]

    def index
      @discount_codes = @event.discount_codes.order(created_at: :desc)
    end

    def new
      @discount_code = @event.discount_codes.new
    end

    def create
      @discount_code = @event.discount_codes.new(discount_code_params)

      if @discount_code.save
        redirect_to admin_event_discount_codes_path(@event), notice: "Discount code was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @discount_code.update(discount_code_params)
        redirect_to admin_event_discount_codes_path(@event), notice: "Discount code was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @discount_code.destroy
      redirect_to admin_event_discount_codes_path(@event), notice: "Discount code was successfully deleted."
    end

    private

    def set_event
      @event = Event.friendly.find(params[:event_id])
    end

    def set_discount_code
      @discount_code = @event.discount_codes.find(params[:id])
    end

    def discount_code_params
      params.require(:discount_code).permit(
        :code, :discount_type, :discount_amount, :max_uses,
        :valid_until, :active, ticket_ids: []
      )
    end
  end
end
