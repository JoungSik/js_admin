module JSAdmin
  class ResourcesController < ApplicationController
    before_action :set_resource
    before_action :set_record, only: %i[show edit update destroy]

    def index
      @page = [ params.fetch(:page, 1).to_i, 1 ].max
      @records = @resource.records(page: @page)
      @total_count = @resource.count
    end

    def show
    end

    def new
      @record = @resource.new_record
    end

    def create
      @record = @resource.new_record(resource_params)

      if @record.save
        redirect_to resource_path(@resource.model_id, @record), notice: "#{@resource.singular_label} was created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @record.update(resource_params)
        redirect_to resource_path(@resource.model_id, @record), notice: "#{@resource.singular_label} was updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      redirect_to resources_path(@resource.model_id), notice: "#{@resource.singular_label} was deleted."
    end

    private

    def set_resource
      @resource = JSAdmin.resource_for!(params[:model_id])
    end

    def set_record
      @record = @resource.find(params[:id])
    end

    def resource_params
      params
        .fetch(@resource.param_key, ActionController::Parameters.new)
        .permit(*@resource.editable_fields.map(&:name))
    end
  end
end
