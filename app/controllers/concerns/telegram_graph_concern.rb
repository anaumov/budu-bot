# frozen_string_literal: true

module TelegramGraphConcern
  private

  def respond_with_graph
    prepearing_message = respond_with(:message, text: 'Подготовка графика...').dig('result')
    service = GraphService.new(current_user)
    graph_file = service.render_image
    bot.delete_message(message_id: prepearing_message['message_id'], chat_id: prepearing_message['chat']['id'])
    respond_with :photo, photo: graph_file
    service.remove_file(graph_file)
  end
end
