# frozen_string_literal: true

require 'csv'
class TestResultsExportService
  def self.perform(user)
    new(user).perform
  end

  def initialize(user)
    @user = user
  end

  def perform
    time = I18n.l(Time.zone.now, format: '%d.%m.%Y_%H%M')
    file = File.new("export_#{time}.csv", 'w+')
    file.puts(csv_data)
    file.rewind
    file
  end

  private

  attr_reader :user

  def csv_data
    CSV.generate do |csv|
      csv << ['вирусная нагрузка', 'иммунный статус', 'дата']
      user.test_results.order(date: :asc).group_by(&:date).each do |date, results|
        immune_status = results.find(&:immune_status?)
        viral_load = results.find(&:viral_load?)
        csv << [viral_load&.value, immune_status&.value, date.strftime('%d.%m.%Y')]
      end
    end
  end
end
