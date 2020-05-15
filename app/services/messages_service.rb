# frozen_string_literal: true

class MessagesService
  def self.results_as_table(user)
    rows = []
    user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?)
      rows << [viral_load&.value, immune_status&.value, date.strftime('%d.%m.%Y')]
    end
    headings = ['вирусная нагрузка', 'иммунный статус', 'дата']
    table = Terminal::Table.new(headings: headings, rows: rows)
    table.align_column(0, :right)
    table.align_column(1, :right)
    table.to_s
  end
end
