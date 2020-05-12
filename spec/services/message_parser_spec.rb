# frozen_string_literal: true

describe MessageParser do
  describe '#create_test_result!' do
    subject(:parse_message) { described_class.perform(message) }

    let(:message_attrs) { { result_type: 'viral_load', value: 100, date: Date.new(2006, 8, 12) } }
    let(:message) { "В #{message_attrs[:value]} #{message_attrs[:date].strftime('%d.%m.%Y')}" }

    it 'resurn array of results' do
      expect(parse_message).to include(message_attrs[:result_type], message_attrs[:value], message_attrs[:date])
    end

    context 'when date is invalid' do
      let(:message) { "В #{message_attrs[:value]} test" }

      it 'creates test result for today' do
        expect(parse_message).to include(message_attrs[:result_type], message_attrs[:value], Date.today)
      end
    end

    context 'when date is missed' do
      let(:message) { "В #{message_attrs[:value]}" }

      it 'creates test result for today' do
        expect(parse_message).to include(message_attrs[:result_type], message_attrs[:value], Date.today)
      end
    end

    context 'when message without shorthand' do
      let(:message) { "вирусная нагрузка #{message_attrs[:value]} #{message_attrs[:date].strftime('%d.%m.%Y')}" }

      it 'creates test result for today' do
        expect(parse_message).to include(message_attrs[:result_type], message_attrs[:value], message_attrs[:date])
      end
    end

    context 'when message invalid' do
      let(:message) { 'test' }

      it 'raises an error' do
        expect { parse_message }.to raise_error(MessageParser::Error)
      end
    end
  end
end
