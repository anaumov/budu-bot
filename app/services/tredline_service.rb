# frozen_string_literal: true

class TredlineService
  Tredilne = Struct.new(:a, :b)

  def self.perform(points)
    new.perform(points)
  end

  def perform(points)
    return Tredilne.new(-0.3, points.first.y) if points.size == 1

    # Formula https://math.stackexchange.com/questions/204020
    a = numerator(points) / denominator(points).to_f
    Tredilne.new(a, calculate_b(points, a))
  end

  private

  def denominator(points)
    denominator = points.size * points.map { |p| p.x**2 }.sum
    denominator - points.map(&:x).sum**2
  end

  def numerator(points)
    numerator = points.size * points.map { |p| p.x * p.y }.sum
    numerator - points.map(&:x).sum * points.map(&:y).sum
  end

  def calculate_b(points, a) # rubocop:disable Naming/MethodParameterName
    numerator = points.map(&:y).sum - a * points.map(&:x).sum
    numerator / points.size.to_f
  end
end
