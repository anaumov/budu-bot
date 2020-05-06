# frozen_string_literal: true

module TelegramGraphConcern
  private

  def respond_with_graph(graph_type)
    service = GraphService.new(current_user)
    graph_file = service.render_image(graph_type)
    send_message(I18n.t(graph_type, scope: %i[test_result result_type]))
    respond_with :photo, photo: graph_file
    service.remove_file(graph_file)
  end
end
