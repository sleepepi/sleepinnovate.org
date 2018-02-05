# frozen_string_literal: true

# Default helper for methods used in views.
module ApplicationHelper
  def simple_check(checked)
    if checked
      content_tag :i, nil, class: %w(fa fa-check-square-o)
    else
      content_tag :i, nil, class: %w(fa fa-square-o)
    end
  end

  def simple_bold(text)
    sanitize(text.to_s.gsub(/\*\*(.*?)\*\*/, "<strong>\\1</strong>"), tags: %w(strong))
  end
end
