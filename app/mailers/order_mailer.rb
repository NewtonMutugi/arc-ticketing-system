class OrderMailer < ApplicationMailer
  default from: "tickets@rubyconf.africa"
  layout "mailer_card"

  def receipt_email(order)
    @order = order
    @event = order.order_items.first.ticket.event

    # Attach logo inline for email display
    attachments.inline["ruby_conf_logo_white.png"] = File.read(Rails.root.join("app/assets/images/ruby_conf_logo_white.png"))

    # Set layout variables
    @email_subtitle = "Order Received"
    @email_title = "Payment Verification in Progress"

    mail(
      to: @order.buyer_email,
      subject: "Order Received: #{@order.order_no} - Verification Pending"
    )
  end

  def confirmation_email(order)
    @order = order
    @event = order.order_items.first.ticket.event

    # Attach logo inline for email display
    attachments.inline["ruby_conf_logo_white.png"] = File.read(Rails.root.join("app/assets/images/ruby_conf_logo_white.png"))

    # Set layout variables
    event_name = @order.order_items.first&.ticket&.event&.title || "the event"
    @email_subtitle = "Payment Verified"
    @email_title = "You are going to #{event_name}!"

    mail(
      to: @order.buyer_email,
      subject: "Your tickets for #{@event.title}"
    )
  end

  def rejection_email(order)
    @order = order
    @event = order.order_items.first.ticket.event

    # Attach logo inline for email display
    attachments.inline["ruby_conf_logo_white.png"] = File.read(Rails.root.join("app/assets/images/ruby_conf_logo_white.png"))

    # Set layout variables
    @email_subtitle = "Payment Rejected"
    @email_title = "Unfortunately, your payment was rejected"

    mail(
      to: @order.buyer_email,
      subject: "Payment Rejected for Order ##{@order.order_no}"
    )
  end

  def attendee_ticket_email(attendee)
    @attendee = attendee
    @order = attendee.order
    @event = attendee.ticket.event

    # Attach logo inline for email display
    attachments.inline["ruby_conf_logo_white.png"] = File.read(Rails.root.join("app/assets/images/ruby_conf_logo_white.png"))

    # Attach individual ticket PDF
    pdf = TicketPdfGenerator.new(@order, [@attendee]).render
    attachments["RubyConf_Ticket_#{@attendee.token}.pdf"] = pdf

    # Set layout variables
    @email_subtitle = "Your Ticket"
    @email_title = "See you at #{@event.title}!"

    mail(
      to: @attendee.email,
      subject: "Your ticket for #{@event.title}"
    )
  end

  def ticket_change_email(attendee, old_ticket)
    @attendee = attendee
    @order = attendee.order
    @event = attendee.ticket.event
    @old_ticket = old_ticket

    # Attach logo inline for email display
    attachments.inline["ruby_conf_logo_white.png"] = File.read(Rails.root.join("app/assets/images/ruby_conf_logo_white.png"))

    # Attach the new individual ticket PDF
    pdf = TicketPdfGenerator.new(@order, [@attendee]).render
    attachments["RubyConf_Ticket_#{@attendee.token}.pdf"] = pdf

    # Set layout variables
    @email_subtitle = "Ticket Update"
    @email_title = "Your ticket has been updated"

    # Send to both the attendee and the buyer
    recipients = [@attendee.email, @order.buyer_email].compact.map(&:downcase).uniq

    mail(
      to: recipients,
      subject: "Ticket Update for #{@event.title}"
    )
  end
end
