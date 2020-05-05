# frozen_string_literal: true

module TelegramGraphConcern
  private

  def immune_status_graph
    service = GraphService.new(current_user)
    immune_status_graph = service.render_image(:immune_status)
    send_message('Иммунный статус')
    respond_with :photo, photo: immune_status_graph
    File.delete(immune_status_graph.path) if File.exist?(immune_status_graph.path)
  end

  def viral_load_graph
    service = GraphService.new(current_user)
    viral_load_graph = service.render_image(:viral_load)
    send_message('Вирусная нагрузка')
    respond_with :photo, photo: viral_load_graph
    File.delete(viral_load_graph.path) if File.exist?(viral_load_graph.path)
  end
end
