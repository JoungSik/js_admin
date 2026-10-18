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
      flash_type, message = if destroy_record
        [ :notice, t("js_admin.resources.notices.deleted", resource: @resource.singular_label) ]
      else
        [ :alert, destroy_failure_message ]
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now[flash_type] = message
          load_records
        end
        format.html { redirect_to resources_path(@resource.model_id), flash_type => message }
      end
    end

    private

    def set_resource
      @resource = JSAdmin.resource_for!(params[:model_id])
    end

    def set_record
      @record = @resource.find(params[:id])
    end

    def destroy_record
      @record.destroy
    rescue ActiveRecord::InvalidForeignKey
      @record.errors.add(:base, t("js_admin.resources.alerts.referenced"))
      false
    end

    def destroy_failure_message
      [
        t("js_admin.resources.alerts.delete_failed", resource: @resource.singular_label),
        *@record.errors.full_messages
      ].join(" ")
    end

    def load_records
      @record_query = RecordQuery.new(
        @resource,
        search_term: string_param(:q),
        filter_values: filter_params,
        sort_column: string_param(:sort),
        sort_direction: string_param(:direction)
      )
      records_scope = @record_query.scope
      @total_count = records_scope.count
      @total_pages = @resource.total_pages(total_count: @total_count)
      @page = [ [ params.fetch(:page, 1).to_i, 1 ].max, @total_pages ].min
      @records = @resource.records(page: @page, scope: records_scope)
    end

    def string_param(key)
      params[key] if params[key].is_a?(String)
    end

    def filter_params
      filters = params[:filters]
      return {} unless filters.respond_to?(:permit)

      filters.permit(*@resource.filter_fields.map(&:name)).to_h
    end

    def resource_params
      params
        .fetch(@resource.param_key, ActionController::Parameters.new)
        .permit(*@resource.form_fields.map(&:name))
    end
  end
end
