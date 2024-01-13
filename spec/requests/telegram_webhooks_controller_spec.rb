# frozen_string_literal: true

require 'telegram/bot/rspec/integration/rails'

RSpec.describe TelegramWebhooksController, telegram_bot: :rails do
  let(:user) { create :user }
  let(:chat) { { chat: { id: user.telegram_chat_id } } }

  before do
    allow(Message).to receive(:build)
  end

  describe '#start!' do
    subject(:start!) { dispatch_command(:start, chat) }

    it 'send hello message and start setup' do
      start!
      expect(Message).to have_received(:build).with(:on_start, any_args)
    end

    context 'when notification already set' do
      before do
        user.update(notification_time: 10)
      end

      it 'sends hello message' do
        start!
        expect(Message).to have_received(:build).with(:on_start, any_args)
        expect(Message).not_to have_received(:build).with(:init_notifications_setup)
      end
    end
  end

  describe '#table!' do
    subject(:table!) { dispatch_command(:table, chat) }

    it 'retuns no results message' do
      table!
      expect(Message).to have_received(:build).with(:no_test_results)
    end

    context 'when user has test_results' do
      before do
        create :test_result, user: user
        allow(MessagesService).to receive(:formatted_table)
        allow(TestResultsExportService).to receive(:perform).and_call_original
      end

      it 'retuns message with results' do
        table!
        expect(MessagesService).to have_received(:formatted_table).with(user)
      end

      it 'retuns csv file' do
        table!
        expect(TestResultsExportService).to have_received(:perform).with(user)
      end
    end
  end

  describe '#graph!' do
    subject(:graph!) { dispatch_command(:graph, chat) }

    before do
      graph = File.open(File.join(Rails.root, 'spec', 'fixtures', 'graph.png'))
      # rubocop:disable RSpec/AnyInstance
      # NOTE: it's only to speed up specs
      allow_any_instance_of(GraphService).to receive(:render_image).and_return(graph)
      # rubocop:enable RSpec/AnyInstance
    end

    it 'retuns no results message' do
      graph!
      expect(Message).to have_received(:build).with(:no_test_results)
    end

    xcontext 'when user has test results' do
      before do
        create :test_result, user: user
      end

      it 'retuns graph' do
        expect { graph! }.to make_telegram_request(bot, :sendPhoto)
      end
    end
  end

  describe '#help!' do
    subject(:help!) { dispatch_command(:help, chat) }

    it 'sends help message' do
      help!
      expect(Message).to have_received(:build).with(:help)
    end
  end

  describe '#message' do
    subject(:receive_message) { dispatch_message("hello", message_params) }

    let(:message_params) { { from: { id: 123 } , chat: { id: user.telegram_chat_id } } } 

    context 'when user inactive' do
      before { user.deactivate! }

      it 'does nothing' do
        receive_message
        expect(Message).not_to have_received(:build)
      end
    end

    context 'when bot blocked by user' do
      before do
        allow(Message).to receive(:build).and_raise(Telegram::Bot::Forbidden)
      end

      it 'deactivates user' do
        receive_message
        expect(user.reload).to be_inactive
      end
    end
  end
end
