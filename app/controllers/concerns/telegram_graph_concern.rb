# frozen_string_literal: true

# FIXME: move to separate class
module TelegramGraphConcern
  private

  attr_reader :prepearing_message

  def respond_with_graph
    return if current_user.test_results.empty?

    send_prepearing_message
    graph_file = graph_service.render_image
    respond_with :photo, photo: graph_file
    remove_preparing_message
    # respond_with :document, document: graph_file
    graph_service.remove_file(graph_file)
  end

  def send_prepearing_message
    @prepearing_message = respond_with(:message, text: 'Подготовка графика...').dig('result')
  end

  def remove_preparing_message
    bot.delete_message(
      message_id: prepearing_message['message_id'],
      chat_id: prepearing_message['chat']['id']
    )
  end

  def graph_service
    @graph_service ||= GraphService.new(current_user)
  end
end
