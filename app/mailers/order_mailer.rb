class OrderMailer < ApplicationMailer
  default from: "tickets@rubyconf.africa"

  def receipt_email(order)
    @order = order
    @event = order.order_items.first.ticket.event

    mail(
      to: @order.buyer_email,
      subject: "Order Received: #{@order.order_no} - Verification Pending"
    )
  end

  def confirmation_email(order)
    @order = order
    @event = order.order_items.first.ticket.event

    pdf = TicketPdfGenerator.new(@order).render

    attachments["RubyConf_Tickets_#{@order.order_no}.pdf"] = pdf

    mail(
      to: @order.buyer_email,
      subject: "Your tickets for #{@event.title}"
    )
  end
end
