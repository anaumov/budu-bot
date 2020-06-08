# frozen_string_literal: true

class MessagesService
  def self.formatted_table(user)
    new(user).formatted_table
  end

  def initialize(user)
    @user = user
  end

  def formatted_table
    rows = [%w[ВН CD4 Дата]]
    rows << :separator
    user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?)
      rows << [format_value(viral_load), format_value(immune_status), date.strftime('%d.%m.%Y')]
    end
    table = Terminal::Table.new(rows: rows)
    table.style = { border_x: '-', border_y: '', border_i: '', border_top: false, border_bottom: false }
    table.align_column(0, :right)
    table.align_column(1, :right)
    table.to_s
  end

  def self.plain_table(user)
    result = []
    user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?)
      result << "#{immune_status&.value} #{viral_load&.value} #{date.strftime('%d.%m.%Y')}"
    end
    result.join("\n")
  end

  private

  attr_reader :user

  def format_value(result)
    if result&.value.present?
      result.value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
    else
      ' '
    end
    # NOTE: space needed for proper table formating
    # result&.value || ' '
  end
end
