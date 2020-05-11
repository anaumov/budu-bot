# frozen_string_literal: true

describe PillNotificationService do
  subject(:notify_users) { described_class.notify_users }

  let(:bot) { Telegram.bot }
  let(:current_hour) { Time.zone.now.hour }
  let(:user) { create(:user, notification_time: hour) }

  before do
    user
    allow(Message).to receive(:build).and_return(instance_double('Message', slug: :test))
    allow(bot).to receive(:send_message)
  end

  context 'when no users have settings on hour' do
    let(:hour) { current_hour - 8.hour }

    it 'does not send any messages' do
      notify_users
      expect(Message).not_to have_received(:build)
      expect(bot).not_to have_received(:send_message)
    end
  end

  context 'when user has settings on an hour' do
    let(:hour) { current_hour }

    it 'sends first message to user' do
      notify_users
      expect(Message).to have_received(:build).with(:daily_first, any_args)
      expect(bot).to have_received(:send_message)
    end
  end

  context 'when user didnt get a pill an hour ago' do
    let(:hour) { current_hour - 1 }

    it 'sends second message to user' do
      notify_users
      expect(Message).to have_received(:build).with(:daily_second, any_args)
      expect(bot).to have_received(:send_message)
    end
  end

  context 'when user didnt get a pill 2 hours ago' do
    let(:hour) { current_hour - 2 }

    it 'sends third message to user' do
      notify_users
      expect(Message).to have_received(:build).with(:daily_undone, any_args)
      expect(bot).to have_received(:send_message)
    end
  end

  context 'when user didnt get a pill 4 hours ago' do
    let(:hour) { current_hour - 3 }

    it 'build undone message' do
      notify_users
      expect(Message).to have_received(:build).with(:undone, any_args)
    end

    it 'sends message' do
      notify_users
      expect(bot).to have_received(:send_message)
    end

    it 'creates user_action' do
      expect { notify_users }.to change(UserAction, :count).from(0).to(1)
    end

    it 'creates undone action' do
      notify_users
      action = UserAction.last
      expect(action).to have_attributes(user: user, action_type: 'pill_undone')
    end
  end
end
