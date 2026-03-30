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

    # Attach ticket PDF
    pdf = TicketPdfGenerator.new(@order).render
    attachments["RubyConf_Tickets_#{@order.order_no}.pdf"] = pdf

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
end
