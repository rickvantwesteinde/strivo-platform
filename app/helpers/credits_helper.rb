# frozen_string_literal: true
module CreditsHelper
  def credit_delta(amount)
    cls  = amount.positive? ? "text-success" : "text-danger"
    sign = amount.positive? ? "+" : ""
    %(<span class="#{cls}">#{sign}#{amount}</span>).html_safe
  end

  # Genereer een simpele inline SVG sparkline voor cumulatief saldo
  # values: array van getallen (bijv. [2,5,3,7])
  # width/height: px
  def sparkline_svg(values, width: 280, height: 40, stroke_width: 2)
    return "" if values.blank?
    min = values.min.to_f
    max = values.max.to_f
    range = (max - min).nonzero? || 1.0

    step_x = values.size > 1 ? (width.to_f / (values.size - 1)) : 0
    points = values.each_with_index.map do |v, i|
      x = (i * step_x).round(2)
      # y omdraaien (0 bovenaan)
      y = (height - ((v - min) / range) * height).round(2)
      "#{x},#{y}"
    end.join(" ")

    %(
      <svg viewBox="0 0 #{width} #{height}" width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg" aria-label="Saldo sparkline">
        <polyline fill="none" stroke="currentColor" stroke-width="#{stroke_width}" points="#{points}" />
      </svg>
    ).html_safe
  end
end
