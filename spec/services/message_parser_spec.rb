# frozen_string_literal: true

describe MessageParser do
  describe '#create_test_result!' do
    subject(:parse_message) { described_class.perform(message) }

    let(:message_attrs) { { result_type: 'viral_load', value: 100, date: Date.new(2006, 8, 6) } }
    let(:message) { "В #{message_attrs[:value]} #{message_attrs[:date].strftime('%d.%m.%Y')}" }

    it 'return array of results' do
      expect(parse_message.last).to include(message_attrs[:result_type], message_attrs[:value], message_attrs[:date])
    end

    it 'return array size of one' do
      expect(parse_message.size).to eq(1)
    end

    context 'when day and month are one digit' do
      let(:message) { "В #{message_attrs[:value]} #{message_attrs[:date].strftime('%-d-%-m-%Y')}" }

      it 'creates test result' do
        expect(parse_message.last).to include(message_attrs[:result_type], message_attrs[:value], message_attrs[:date])
      end
    end

    context 'when date is invalid' do
      let(:message) { "В #{message_attrs[:value]} test" }

      it 'creates test result for today' do
        expect(parse_message.last).to include(message_attrs[:result_type], message_attrs[:value], Date.today)
      end
    end

    context 'when date is missed' do
      let(:message) { "В #{message_attrs[:value]}" }

      it 'creates test result for today' do
        expect(parse_message.last).to include(message_attrs[:result_type], message_attrs[:value], Date.today)
      end
    end

    context 'when message without shorthand' do
      let(:message) { "вирусная нагрузка #{message_attrs[:value]} #{message_attrs[:date].strftime('%d.%m.%Y')}" }

      it 'creates test result for today' do
        expect(parse_message.last).to include(message_attrs[:result_type], message_attrs[:value], message_attrs[:date])
      end
    end

    context 'when message invalid' do
      let(:message) { 'test' }

      it 'raises an error' do
        expect { parse_message }.to raise_error(MessageParser::Error)
      end
    end

    context 'when message has both kind of results' do
      let(:message_attrs) { { viral_load: 0, immune_status: 500, date: Date.new(2006, 8, 6) } }
      let(:message) { "#{message_attrs[:immune_status]} #{message_attrs[:viral_load]} #{message_attrs[:date].strftime('%d.%m.%Y')}" }

      it 'returns array size of two' do
        expect(parse_message.size).to eq(2)
      end

      it 'returns immune_status' do
        expect(parse_message.first).to include(:immune_status, message_attrs[:immune_status], message_attrs[:date])
      end

      it 'and viral_load' do
        expect(parse_message.last).to include(:viral_load, message_attrs[:viral_load], message_attrs[:date])
      end
    end
  end
end
