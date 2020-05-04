# frozen_string_literal: true

class MessagesService
  def self.results_as_table(user)
    result = "Дата       ВН         CD4\n"
    user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
      immune_status = results.find(&:immune_status?)
      viral_load = results.find(&:viral_load?)&.value&.to_s || ''
      viral_load = viral_load.size < 6 ? (viral_load + ' ' * 2 * (6 - viral_load.size)) : viral_load
      result += "#{date.strftime('%d.%m.%y')}  #{viral_load}  #{immune_status&.value}\n"
    end
    result
  end
end
