# frozen_string_literal: true

class GraphRenderer
  def initialize(params)
    @params = params
  end

  def image
    kit = IMGKit.new(html, quality: 100, width: Graph.canvas_width, height: Graph.canvas_height)
    kit.stylesheets << stylesheet_path
    kit.to_file('current_graph.png')
  end

  def html
    ActionController::Base.new.render_to_string(
      template: 'graphs/show',
      layout: false,
      locals: params
    )
  end

  private

  attr_reader :params

  def stylesheet_path
    builder = Sprockets::Railtie.build_environment(Rails.application)
    asset = builder.find_asset('graph.css', base_path: Rails.application.root.to_s)
    Rails.root.join('public', 'assets', asset.digest_path)
  end
end
