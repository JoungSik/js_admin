module JSAdmin
  class ResourcesController < ApplicationController
    before_action :set_resource
    before_action :set_record, only: %i[show edit update destroy]

    def index
      load_records
    end

    def show
    end

    def new
      @record = @resource.new_record
    end

    def create
      @record = @resource.new_record(resource_params)

      if @record.save
        redirect_to resource_path(@resource.model_id, @record),
                    notice: t("js_admin.resources.notices.created", resource: @resource.singular_label)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @record.update(resource_params)
        redirect_to resource_path(@resource.model_id, @record),
                    notice: t("js_admin.resources.notices.updated", resource: @resource.singular_label)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      message = t("js_admin.resources.notices.deleted", resource: @resource.singular_label)

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = message
          load_records
        end
        format.html { redirect_to resources_path(@resource.model_id), notice: message }
      end
    end

    private

    def set_resource
      @resource = JSAdmin.resource_for!(params[:model_id])
    end

    def set_record
      @record = @resource.find(params[:id])
    end

    def load_records
      @total_count = @resource.count
      @total_pages = @resource.total_pages(total_count: @total_count)
      @page = [ [ params.fetch(:page, 1).to_i, 1 ].max, @total_pages ].min
      @records = @resource.records(page: @page)
    end

    def resource_params
      params
        .fetch(@resource.param_key, ActionController::Parameters.new)
        .permit(*@resource.editable_fields.map(&:name))
    end
  end
end
