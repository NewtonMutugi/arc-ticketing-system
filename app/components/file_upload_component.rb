# frozen_string_literal: true

class FileUploadComponent < ViewComponent::Base
  def initialize(form:, field:, label: "Upload File", accept: "image/*")
    @form = form
    @field = field
    @label = label
    @accept = accept
  end
end
