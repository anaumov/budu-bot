# frozen_string_literal: true

module TelegramGraphConcern
  private

  def respond_with_graph
    service = GraphService.new(user: current_user, width: 600, height: 400)
    graph_file = service.render_image
    # send_message(I18n.t(graph_type, scope: %i[test_result result_type]))
    respond_with :photo, photo: graph_file
    service.remove_file(graph_file)
  end
end
