class CheckInsPdfGenerator
  require "prawn/table"

  def initialize(event, attendees, date)
    @event = event
    @attendees = attendees
    @date = date
  end

  def render
    pdf = Prawn::Document.new(page_layout: :landscape)
    pdf.font_families.update("Helvetica" => {
      normal: "Helvetica",
      bold: "Helvetica-Bold",
      italic: "Helvetica-Oblique",
      bold_italic: "Helvetica-BoldOblique"
    })

    pdf.font "Helvetica"

    # Header
    pdf.text "Check-ins for #{@event.title} on #{@date}", size: 20, style: :bold
    pdf.move_down 10
    pdf.text "Generated on #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 10, color: "777777"
    pdf.move_down 20

    # Table data
    table_data = [ [ "First Name", "Last Name", "Email", "Ticket Type", "Order No", "Checked In At" ] ]

    @attendees.each do |attendee|
      check_in = attendee.check_ins.find { |c| c.date == @date }
      table_data << [
        attendee.first_name,
        attendee.last_name,
        attendee.email,
        attendee.ticket.title,
        "##{attendee.order.order_no}",
        check_in&.created_at&.strftime("%Y-%m-%d %H:%M:%S")
      ]
    end

    # Render Table
    pdf.table(table_data, header: true, width: pdf.bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "EEEEEE"
      cells.padding = 8
      cells.borders = [ :bottom ]
      cells.border_width = 0.5
      cells.border_color = "DDDDDD"
    end

    pdf.render
  end
end
