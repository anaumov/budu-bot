# frozen_string_literal: true

module TelegramGraphConcern
  private

  def respond_with_graph
    respond_with :message, text: 'Готовлю график...'
    service = GraphService.new(user: current_user, width: 600, height: 400)
    graph_file = service.render_image
    respond_with :photo, photo: graph_file
    service.remove_file(graph_file)
  end
end
