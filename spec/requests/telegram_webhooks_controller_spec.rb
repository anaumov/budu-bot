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
      expect(Message).to have_received(:build).with(:init_notifications_setup)
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
      end

      it 'retuns message with results' do
        expect { table! }.to send_telegram_message(bot, MessagesService.results_as_table(user))
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

    context 'when user has test results' do
      before do
        create :test_result, user: user
      end

      it 'retuns no graph' do
        expect { graph! }.to make_telegram_request(bot, :sendPhoto).exactly(2)
      end
    end
  end

  # describe '#setup!' do
  #   context 'when user has test_results' do
  #   end
  # end

  describe '#help!' do
    subject(:help!) { dispatch_command(:help, chat) }

    it 'sends help message' do
      help!
      expect(Message).to have_received(:build).with(:help)
    end
  end
end
