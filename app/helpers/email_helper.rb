# frozen_string_literal: true

# Helper functions for application emails
module EmailHelper
  def emphasis_color
    "#333"
  end

  def success_color
    "#00c853" # $a700; Green
  end

  def warning_color
    "#ffd600" # $a700; Yellow
  end

  def danger_color
    "#d50000" # $a700; Red
  end

  def background_color
    "#fafafa"
  end

  def banner_color
    "#efefef"
  end

  def link_color
    "#03a9f4" # $p500-light-blue
  end

  def center_style
    hash_to_css_string(
      font_size: "17px",
      line_height: "24px",
      margin: "0 0 16px",
      text_align: "center"
    )
  end

  def link_style
    hash_to_css_string(
      color: link_color,
      font_weight: "bold",
      text_decoration: "none",
      word_break: "break-word"
    )
  end

  def p_style
    hash_to_css_string(
      font_size: "17px",
      line_height: "24px",
      margin: "0 0 16px"
    )
  end

  def blockquote_style
    hash_to_css_string(
      font_size: "17px",
      font_style: "italic",
      line_height: "24px",
      margin: "0 0 16px"
    )
  end

  def default_style
    hash_to_css_string(
      font_weight: "bold",
      word_break: "break-word"
    )
  end

  def emphasis_style
    hash_to_css_string(
      color: emphasis_color,
      font_weight: "bold",
      word_break: "break-word"
    )
  end

  def success_style
    hash_to_css_string(
      color: success_color,
      font_weight: "bold",
      word_break: "break-word"
    )
  end

  def warning_style
    hash_to_css_string(
      color: warning_color,
      font_weight: "bold",
      word_break: "break-word"
    )
  end

  def danger_style
    hash_to_css_string(
      color: danger_color,
      font_weight: "bold",
      word_break: "break-word"
    )
  end

  protected

  def hash_to_css_string(hash)
    array = hash.collect do |key, value|
      "#{key.to_s.dasherize}:#{value}"
    end
    array.join(";")
  end
end
