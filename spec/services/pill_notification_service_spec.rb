# frozen_string_literal: true

require 'rails_helper'
describe PillNotificationService do
  subject(:notify_users) { described_class.notify_users }

  let(:bot) { Telegram.bot }
  let(:current_hour) { Time.now.hour }

  before do
    puts 'before_create', User.count
    create(:user, notification_time: hour)
    puts 'after_create', User.count
    allow(Message).to receive(:build).and_return(double)
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
      expect(Message).to have_received(:build).with(:daily_third, any_args)
      expect(bot).to have_received(:send_message)
    end
  end

  context 'when user didnt get a pill 3 hours ago' do
    let(:hour) { current_hour - 3 }

    it 'sends fourth message to user' do
      notify_users
      expect(Message).to have_received(:build).with(:daily_four, any_args)
      expect(bot).to have_received(:send_message)
    end
  end

  context 'when user didnt get a pill 5 hours ago' do
    let(:hour) { current_hour - 4 }

    it 'sends undone message to user' do
      notify_users
      expect(Message).to have_received(:build).with(:daily_undone, any_args)
      expect(bot).to have_received(:send_message)
    end
  end
end
