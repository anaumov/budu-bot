# frozen_string_literal: true

describe TestResultsFactory do
  describe '#create_test_result!' do
    subject(:create_test_result) { described_class.perform(user, message) }

    let(:user) { create :user }
    let(:message) { 'В 400 10.10.2020' }

    it 'creates test_result' do
      expect { create_test_result }.to change(TestResult, :count).from(0).to(1)
    end

    it 'responds with message' do
      expect(create_test_result.last[:message]).to eq(message)
    end

    it 'and test_result' do
      expect(create_test_result.last[:result]).to all(be_an(TestResult))
    end

    context 'when message is invalid' do
      let(:message) { 'test' }

      it 'responds with nil' do
        expect(create_test_result).to include(message: message, result: nil)
      end
    end

    context 'when multi line message' do
      let(:message) { "В 400 10.10.2020\nИ 400 11.10.2020\nВ 400 12.10.2020" }

      it 'creates test_results' do
        expect { create_test_result }.to change(TestResult, :count).from(0).to(3)
      end

      context 'when one row is invalid' do
        let(:message) { "В 400 10.10.2020\ntest\nВ 400 12.10.2020" }

        it 'responds with nil' do
          expect(create_test_result).to include({ message: 'test', result: nil })
        end
      end
    end
  end
end
