module ApplicationHelper
  def safe_return_to(path, default_path)
    return default_path unless path.is_a?(String)
    path.start_with?("/") && !path.start_with?("//") ? path : default_path
  end
end
