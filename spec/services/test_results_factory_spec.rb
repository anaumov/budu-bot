# frozen_string_literal: true

describe TestResultsFactory do
  describe '#create_test_result!' do
    subject(:factory_action) { described_class.new(user, message).create_test_result! }

    let(:user) { create :user }
    let(:message_attributes) { { result_type: 'viral_load', value: 100, date: Date.new(2006, 8, 12) } }
    let(:message) { "В #{message_attributes[:value]} #{message_attributes[:date].strftime('%d.%m.%Y')}" }

    it 'creates test result' do
      expect(factory_action).to have_attributes(message_attributes)
    end

    context 'when date is invalid' do
      let(:message_attributes) { { result_type: 'viral_load', value: 100, date: Date.today } }
      let(:message) { "В #{message_attributes[:value]} test" }

      it 'creates test result for today' do
        expect(factory_action).to have_attributes(message_attributes)
      end

      context 'when date is missed' do
        let(:message) { "В #{message_attributes[:value]}" }

        it 'creates test result for today' do
          expect(factory_action).to have_attributes(message_attributes)
        end
      end
    end

    context 'when message without shorthand' do
      let(:message) { "вирусная нагрузка #{message_attributes[:value]} #{message_attributes[:date].strftime('%d.%m.%Y')}" }

      it 'creates test result for today' do
        expect(factory_action).to have_attributes(message_attributes)
      end
    end

    context 'when message invalid' do
      let(:message) { 'test' }

      it 'raises an error' do
        expect { factory_action }.to raise_error(TestResultsFactory::Error)
      end
    end
  end
end
