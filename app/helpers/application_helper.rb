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
end
