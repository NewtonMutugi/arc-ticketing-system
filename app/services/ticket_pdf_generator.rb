require "prawn"
require "rqrcode"
require "stringio"

class TicketPdfGenerator
  # 8.5 x 2.5 inches in PDF points (72 dpi)
  PAGE_WIDTH = 612
  PAGE_HEIGHT = 180

  def initialize(order)
    @order = order
    @event = order.order_items.first.ticket.event
  end

  def render
    # Margin 0 is crucial for the full-bleed background
    Prawn::Document.new(page_size: [ PAGE_WIDTH, PAGE_HEIGHT ], margin: 0) do |pdf|
      @order.attendees.each_with_index do |attendee, index|
        pdf.start_new_page if index > 0
        draw_ticket(pdf, attendee)
      end
    end.render
  end

  private

  def draw_ticket(pdf, attendee)
    # --- 1. BACKGROUND IMAGE (Full Bleed) ---
    # This replaces all manual background drawing
    bg_path = Rails.root.join("public", "Ticket-background.png")

    if File.exist?(bg_path)
      # Place image at top-left [0, PAGE_HEIGHT] stretching to full dimensions
      pdf.image bg_path, width: PAGE_WIDTH, height: PAGE_HEIGHT, at: [ 0, PAGE_HEIGHT ]
    else
      # Fallback: Dark Maroon solid color if image is missing
      pdf.fill_color "571217"
      pdf.fill_rectangle [ 0, PAGE_HEIGHT ], PAGE_WIDTH, PAGE_HEIGHT
    end

    # --- 2. LOGO (Top Left) ---
    # We layer the logo ON TOP of the background image
    logo_path = Rails.root.join("public", "ruby_conf_logo.png")

    if File.exist?(logo_path)
      pdf.image logo_path, width: 120, at: [ 20, 160 ]
    else
      # Text Fallback
      pdf.fill_color "FFFFFF"
      pdf.font("Helvetica", style: :bold) do
        pdf.text_box "RubyConf Africa", at: [ 20, 160 ], size: 20
      end
    end

    # "Official Ticket" watermark
    pdf.fill_color "FFFFFF"
    pdf.font("Helvetica", style: :italic) do
      pdf.text_box "Official Ticket", at: [ 340, 160 ], width: 90, size: 8, align: :right, options: { opacity: 0.7 }
    end

    # --- 3. ATTENDEE DETAILS ---

    # Main Content Box
    pdf.bounding_box([ 20, 110 ], width: 400, height: 100) do
      # Row 1: ATTENDEE NAME
      label(pdf, "ATTENDEE")
      value(pdf, "#{attendee.first_name} #{attendee.last_name}".upcase, size: 16)

      pdf.move_down 15

      # Row 2: Grid for details
      y_cursor = pdf.cursor

      # Col 1: Reference
      pdf.bounding_box([ 0, y_cursor ], width: 130, height: 40) do
        label(pdf, "ORDER REF")
        value(pdf, @order.order_no, size: 10)
      end

      # Col 2: Ticket Type
      pdf.bounding_box([ 140, y_cursor ], width: 130, height: 40) do
        label(pdf, "TICKET TYPE")
        value(pdf, attendee.ticket.title.upcase, size: 10)
      end

      # Col 3: Date
      pdf.bounding_box([ 280, y_cursor ], width: 100, height: 40) do
        label(pdf, "DATE")
        value(pdf, @event.start_date.strftime("%b %d, %Y").upcase, size: 10)
      end
    end

    # --- 4. TEAR-OFF LINE ---
    # We keep this to visually separate the stub, even with the background image
    pdf.stroke_color "FFFFFF"
    pdf.line_width 1
    pdf.dash([ 4, 4 ])
    pdf.stroke_vertical_line(0, PAGE_HEIGHT, at: 440)
    pdf.undash

    # --- 5. QR CODE (On Stub) ---
    # White background box for scanability
    box_left = 466
    box_top  = 150
    box_size = 120

    # White background box
    pdf.fill_color "000000"
    pdf.fill_rectangle [ 442, 200 ], 200, 200

    pdf.bounding_box([ box_left, box_top ], width: box_size, height: box_size) do
      qr_data = "Order:#{@order.order_no}|Token:#{attendee.token}"
      qr = RQRCode::QRCode.new(qr_data)
      qr_png = qr.as_png(size: 170, border_modules: 0)

      # vposition: :center ensures the QR image is vertically aligned inside the white box
      pdf.image StringIO.new(qr_png.to_s), width: 100, position: :center, vposition: :center
    end

    # Token text - Positioned just below the white box
    # The box ends at y = 30 (150 - 120). We place text at y = 25.
    pdf.fill_color "ffffff"
    pdf.font("Helvetica", style: :normal) do
      pdf.text_box attendee.token, at: [ box_left, 25 ], width: box_size, height: 10, size: 8, align: :center
    end
  end

  # Helper for labels (Light Peach/Gray color)
  def label(pdf, text)
    pdf.font("Helvetica", style: :bold) do
      pdf.fill_color "D9A5A8"
      pdf.text text, size: 7
      pdf.move_down 2
    end
  end

  # Helper for values (Bright White)
  def value(pdf, text, size: 12)
    pdf.font("Helvetica", style: :bold) do
      pdf.fill_color "FFFFFF"
      pdf.text text, size: size, overflow: :shrink_to_fit
    end
  end
end
