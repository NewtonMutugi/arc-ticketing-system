# frozen_string_literal: true

class ToastComponent < ViewComponent::Base
  TYPES = {
    success: {
      wrapper: "border-green-500 bg-green-50",
      title: "text-green-800",
      content: "text-green-700",
      svg: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="-mt-0.5 size-6 text-green-700">
      <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
    </svg>'
    },
    error: {
      wrapper: "border-red-500 bg-red-50",
      title: "text-red-800",
      content: "text-red-700",
      svg: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="-mt-0.5 size-6 text-red-700">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z"></path>
    </svg>'
    },
    warning: {
      wrapper: "border-amber-500 bg-amber-50",
      title: "text-amber-800",
      content: "text-amber-700",
      svg: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="-mt-0.5 size-6 text-amber-700">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"></path>
    </svg>'
    },
    info: {
      wrapper: "border-blue-500 bg-blue-50",
      title: "text-blue-800",
      content: "text-blue-700",
      svg: '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="-mt-0.5 size-6 text-blue-700">
      <path stroke-linecap="round" stroke-linejoin="round" d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z"></path>
    </svg>'
    }
  }
  def initialize(type: :info, title:, body:, **args)
    @type = TYPES[type.to_sym] || TYPES[:info]
    @args = args
    @title = title
    @body = body
  end

  def wrapper_classes
    base = "rounded-md border p-4 shadow-sm"
    class_names(base, @type[:wrapper], @args[:class])
  end

  def svg
    @type[:svg].html_safe
  end

  def title_classes
    class_names(@type[:title])
  end

  def body_classes
    class_names(@type[:content])
  end
end
