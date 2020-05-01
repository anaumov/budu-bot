# frozen_string_literal: true

class MessageDecorator < BaseDecorator
  def text
    html = Kramdown::Document.new(object.text).to_html
    html = html[..-2] # remove last \n
    html = html.gsub("\n", '<br />') # proper line breaks
    html[3..-5].html_safe # remove <p>...</p> wrapper
  end
end
