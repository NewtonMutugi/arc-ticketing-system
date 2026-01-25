require "prawn"
require "rqrcode"

class TicketPdfGenerator
  def initialize(order)
    @order = order
    @event = order.order_items.first.ticket.event
  end

  def render
    Prawn::Document.new(page_size: "A4") do |pdf|
      @order.attendees.each_with_index do |attendee, index|
        pdf.start_new_page if index > 0

        # Header
        pdf.fill_color "CC0000"
        pdf.fill_rectangle [ 0, pdf.cursor ], pdf.bounds.width, 80

        pdf.move_down 20
        pdf.fill_color "FFFFFF"
        pdf.font("Helvetica", style: :bold) do
          pdf.text @order.order_items.first.ticket.event.title, size: 24, align: :center
        end
        pdf.move_down 5
        pdf.text "OFFICIAL TICKET", size: 10, align: :center, spacing: 4

        # --- BODY ---
        pdf.move_down 60
        pdf.fill_color "000000"

        # Event Title
        pdf.font("Helvetica", style: :bold) do
          pdf.text @event.title, size: 22
        end

        pdf.move_down 10
        pdf.text "#{@event.start_date.strftime('%B %d, %Y')} • #{@event.location}", size: 12, color: "555555"

        pdf.stroke_horizontal_rule
        pdf.move_down 20

        # Attendee Details
        pdf.text "ATTENDEE", size: 10, color: "777777"
        pdf.move_down 5
        pdf.font("Helvetica", style: :bold) do
          pdf.text "#{attendee.first_name} #{attendee.last_name}", size: 18
        end

        pdf.move_down 15

        pdf.text "TICKET TYPE", size: 10, color: "777777"
        pdf.move_down 5
        pdf.text attendee.ticket.title, size: 14

        pdf.move_down 15

        pdf.text "ORDER REFERENCE", size: 10, color: "777777"
        pdf.move_down 5
        pdf.text @order.order_no, size: 14

        # --- QR CODE ---
        # Data Format: "Order: [NO] | Attendee: [NAME] | Token: [TOKEN]"
        qr_data = "Order:#{@order.order_no}|Attendee:#{attendee.first_name} #{attendee.last_name}|Token:#{attendee.token}"
        qr = RQRCode::QRCode.new(qr_data)

        # Render QR as PNG blob
        qr_png = qr.as_png(size: 200)

        # Place QR Code at bottom right
        pdf.bounding_box([ 300, 500 ], width: 200, height: 200) do
          pdf.image StringIO.new(qr_png.to_s), width: 150, position: :center
          pdf.move_down 5
          pdf.font_size 8
          pdf.text attendee.token, align: :center, color: "999999"
        end

        # Footer
        pdf.move_cursor_to 50
        pdf.font_size 10
        pdf.text "Please present this QR code at the entrance.", align: :center, color: "555555"
      end
    end.render
  end
end
