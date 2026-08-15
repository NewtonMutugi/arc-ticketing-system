module Public
  class DiscountCodesController < ApplicationController
    allow_unauthenticated_access
    
    def validate
      event = Event.friendly.find(params[:event_id])
      ticket = event.tickets.find(Ticket.decode_id(params[:ticket_id]))
      code = params[:code].to_s.strip.upcase
      
      discount_code = event.discount_codes.find_by(code: code)
      
      if discount_code.nil?
        render json: { valid: false, error: "Invalid discount code." }, status: :not_found
        return
      end
      
      unless discount_code.valid_for_use?
        render json: { valid: false, error: "This discount code is inactive, expired, or has reached its usage limit." }, status: :unprocessable_entity
        return
      end
      
      unless discount_code.applies_to?(ticket)
        render json: { valid: false, error: "This discount code does not apply to the selected ticket." }, status: :unprocessable_entity
        return
      end
      
      render json: {
        valid: true,
        discount_type: discount_code.discount_type,
        discount_amount: discount_code.discount_amount,
        message: "Discount applied successfully!"
      }
    end
  end
end
