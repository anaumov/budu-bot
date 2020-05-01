# frozen_string_literal: true

module Admin
  class BaseController < AdminController
    def index
      render templace: 'admin/views/index', locals: { items: operated_class.ordered.page(page), columns: show_columns }
    end

    def new
      render locals: { item: operated_class.new }
    end

    def show
      render locals: { item: item, columns: show_columns }
    end

    def create
      item = operated_class.create!(permitted_params)
      redirect_to(index_path, notice: "#{item.name} created")
    rescue ActiveRecord::RecordInvalid => e
      render :new, locals: { item: e.record }
    end

    def edit
      render locals: { item: item }
    end

    def update
      item.update!(permitted_params)
      redirect_to(index_path, notice: "Обновил #{item.class.name} #{item.id}")
    rescue ActiveRecord::RecordInvalid => e
      render action: 'edit', locals: { item: e.record }
    end

    def destroy
      item.destroy!
      redirect_to(index_path, notice: "#{item.name} destroyed")
    end

    def model_name
      raise NotImplementedError
    end
    helper_method :model_name

    private

    def show_columns
      raise NotImplementedError
    end

    def index_path
      public_send "admin_#{model_name.pluralize}_path"
    end

    def operated_class
      model_name.camelize.constantize
    end

    def item
      @item ||= operated_class.find params[:id]
    end

    def permitted_params
      raise NotImplementedError
    end
  end
end
