# frozen_string_literal: true

module Admin
  class MessagesController < Admin::BaseController
    SHOW_COLUMNS = %w[desc text].freeze

    private

    def model_name
      'message'
    end

    def show_columns
      SHOW_COLUMNS
    end

    def permitted_params
      params.require(:message).permit(:desc, :text)
    end
  end
end
