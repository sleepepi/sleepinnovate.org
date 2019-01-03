# frozen_string_literal: true

# Default helper for methods used in views.
module ApplicationHelper
  def simple_check(checked)
    checked ? icon("fas", "check-square") : icon("far", "square")
  end

  def simple_bold(text)
    sanitize(text.to_s.gsub(/\*\*(.*?)\*\*/, "<strong>\\1</strong>"), tags: %w(strong))
  end
end
