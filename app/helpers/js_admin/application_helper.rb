module JSAdmin
  module ApplicationHelper
    TEXT_INPUT_CLASSES = [
      "w-full rounded-md border border-slate-300 bg-white px-3.5 py-2.5 text-sm text-slate-950 shadow-sm",
      "placeholder:text-slate-400 focus:border-sky-500 focus:outline-none focus:ring-2 focus:ring-sky-200",
      "dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100 dark:placeholder:text-slate-500",
      "dark:focus:border-sky-400 dark:focus:ring-sky-900"
    ].join(" ")

    SELECT_INPUT_CLASSES = [
      "w-full rounded-md border border-slate-300 bg-white px-3.5 py-2.5 text-sm text-slate-950 shadow-sm",
      "focus:border-sky-500 focus:outline-none focus:ring-2 focus:ring-sky-200",
      "dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100",
      "dark:focus:border-sky-400 dark:focus:ring-sky-900"
    ].join(" ")

    CHECKBOX_INPUT_CLASSES = [
      "h-4 w-4 rounded border-slate-300 text-sky-600 focus:ring-sky-500",
      "dark:border-slate-700 dark:bg-slate-900 dark:focus:ring-sky-700"
    ].join(" ")

    TEXT_INPUT_ERROR_CLASSES = [
      "w-full rounded-md border border-rose-400 bg-white px-3.5 py-2.5 text-sm text-slate-950 shadow-sm",
      "placeholder:text-slate-400 focus:border-rose-500 focus:outline-none focus:ring-2 focus:ring-rose-200",
      "dark:border-rose-500 dark:bg-slate-900 dark:text-slate-100 dark:placeholder:text-slate-500",
      "dark:focus:border-rose-400 dark:focus:ring-rose-950"
    ].join(" ")

    SELECT_INPUT_ERROR_CLASSES = [
      "w-full rounded-md border border-rose-400 bg-white px-3.5 py-2.5 text-sm text-slate-950 shadow-sm",
      "focus:border-rose-500 focus:outline-none focus:ring-2 focus:ring-rose-200",
      "dark:border-rose-500 dark:bg-slate-900 dark:text-slate-100",
      "dark:focus:border-rose-400 dark:focus:ring-rose-950"
    ].join(" ")

    CHECKBOX_INPUT_ERROR_CLASSES = [
      "h-4 w-4 rounded border-rose-400 text-rose-600 focus:ring-rose-500",
      "dark:border-rose-500 dark:bg-slate-900 dark:focus:ring-rose-900"
    ].join(" ")

    FIELD_LABEL_CLASSES = "text-sm font-medium text-slate-700 dark:text-slate-300 sm:col-span-4"
    FIELD_LABEL_ERROR_CLASSES = "text-sm font-medium text-rose-700 dark:text-rose-300 sm:col-span-4"
    FIELD_ERROR_TEXT_CLASSES = "mt-2 text-sm text-rose-600 dark:text-rose-300"
    FORM_ERROR_CLASSES = "rounded-md border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800 dark:border-rose-900 dark:bg-rose-950 dark:text-rose-200"

    SIDEBAR_LINK_BASE_CLASSES = [
      "block rounded-md px-3 py-2 text-sm font-medium",
      "hover:bg-slate-100 hover:text-slate-950",
      "dark:hover:bg-slate-800 dark:hover:text-slate-100"
    ].join(" ")

    SIDEBAR_LINK_ACTIVE_CLASSES = "bg-sky-50 text-sky-700 dark:bg-sky-950 dark:text-sky-200"
    SIDEBAR_LINK_INACTIVE_CLASSES = "text-slate-700 dark:text-slate-300"

    FLASH_BASE_CLASSES = [
      "transform rounded-md border px-4 py-3 text-sm shadow-lg transition duration-300 ease-out"
    ].join(" ")

    FLASH_CLASSES = {
      notice: "border-emerald-200 bg-emerald-50 text-emerald-800 dark:border-emerald-900 dark:bg-emerald-950 dark:text-emerald-200",
      alert: "border-rose-200 bg-rose-50 text-rose-800 dark:border-rose-900 dark:bg-rose-950 dark:text-rose-200"
    }.freeze

    PAGINATION_LINK_CLASSES = [
      "inline-flex h-9 min-w-9 items-center justify-center rounded-md border border-slate-300 bg-white px-3 text-sm font-medium",
      "text-slate-700 shadow-sm hover:bg-slate-50",
      "dark:border-slate-700 dark:bg-slate-900 dark:text-slate-200 dark:hover:bg-slate-800"
    ].join(" ")

    PAGINATION_DISABLED_CLASSES = [
      "inline-flex h-9 min-w-9 items-center justify-center rounded-md border border-slate-200 bg-slate-100 px-3 text-sm font-medium",
      "text-slate-400 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-600"
    ].join(" ")

    PAGINATION_STATUS_CLASSES = [
      "inline-flex h-9 min-w-28 items-center justify-center rounded-md border border-slate-200 bg-slate-50 px-3 text-sm font-medium",
      "text-slate-700 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-200"
    ].join(" ")

    def js_admin_field_input(form, field)
      case field.input_kind
      when :text_area
        tag.textarea(js_admin_field_value(form, field), **js_admin_input_options(form, field, js_admin_text_input_classes(form, field)), rows: 5)
      when :check_box
        tag.div(class: "flex h-10 items-center") do
          safe_join([
            tag.input(type: "hidden", name: js_admin_field_name(form, field), value: "0", autocomplete: "off"),
            tag.input(**js_admin_input_options(form, field, js_admin_checkbox_input_classes(form, field)).merge(type: "checkbox", value: "1", checked: js_admin_checkbox_checked?(form, field)))
          ])
        end
      when :number_field
        tag.input(**js_admin_input_options(form, field, js_admin_text_input_classes(form, field)).merge(type: "number", step: field.number_step, value: js_admin_field_value(form, field)))
      when :date_field
        tag.input(**js_admin_input_options(form, field, js_admin_text_input_classes(form, field)).merge(type: "date", value: js_admin_formatted_field_value(form, field, "%Y-%m-%d")))
      when :datetime_field
        tag.input(**js_admin_input_options(form, field, js_admin_text_input_classes(form, field)).merge(type: "datetime-local", value: js_admin_formatted_field_value(form, field, "%Y-%m-%dT%H:%M:%S")))
      when :time_field
        tag.input(**js_admin_input_options(form, field, js_admin_text_input_classes(form, field)).merge(type: "time", value: js_admin_formatted_field_value(form, field, "%H:%M:%S")))
      when :enum_select
        select_tag(js_admin_field_name(form, field), options_for_select(field.enum_values, js_admin_field_value(form, field)), js_admin_select_options(form, field))
      when :association_select
        select_tag(js_admin_field_name(form, field), options_for_select(field.association_options, js_admin_field_value(form, field)), js_admin_select_options(form, field))
      else
        tag.input(**js_admin_input_options(form, field, js_admin_text_input_classes(form, field)).merge(type: "text", value: js_admin_field_value(form, field)))
      end
    end

    def js_admin_field_id(form, field)
      "#{form.object_name}_#{field.name}".tr("][", "_").delete_suffix("_")
    end

    def js_admin_field_error_id(form, field)
      "#{js_admin_field_id(form, field)}_error"
    end

    def js_admin_field_errors(record, field)
      record.errors[field.name].map(&:to_s)
    end

    def js_admin_form_errors(record, resource)
      editable_attributes = resource.editable_fields.map { |field| field.name.to_sym }

      record.errors.filter_map do |error|
        next if editable_attributes.include?(error.attribute.to_sym)

        error.full_message
      end
    end

    def js_admin_field_label_classes(record, field)
      js_admin_field_errors(record, field).any? ? FIELD_LABEL_ERROR_CLASSES : FIELD_LABEL_CLASSES
    end

    def js_admin_field_error_text_classes
      FIELD_ERROR_TEXT_CLASSES
    end

    def js_admin_form_error_classes
      FORM_ERROR_CLASSES
    end

    def js_admin_table_value(field, record)
      value = field.formatted_value(record)
      classes = value == "NULL" ? "text-slate-400 dark:text-slate-500" : "text-slate-700 dark:text-slate-200"

      tag.span(truncate(value, length: 80), class: classes)
    end

    def js_admin_sidebar_top_level_resources
      js_admin_sidebar_resources.select { |resource| js_admin_resource_namespace(resource).blank? }
    end

    def js_admin_sidebar_namespace_groups
      js_admin_sidebar_resources
        .reject { |resource| js_admin_resource_namespace(resource).blank? }
        .group_by { |resource| js_admin_resource_namespace(resource) }
        .sort_by { |namespace, _resources| namespace }
        .to_h
    end

    def js_admin_sidebar_resource_label(resource)
      resource.model_class.name.demodulize.underscore.humanize
    end

    def js_admin_sidebar_namespace_label(namespace)
      namespace.split("::").map { |name| name.underscore.humanize }.join(" / ")
    end

    def js_admin_sidebar_namespace_open?(resources)
      resources.any? { |resource| js_admin_sidebar_resource_active?(resource) }
    end

    def js_admin_sidebar_link_classes(resource)
      state_classes = if js_admin_sidebar_resource_active?(resource)
        SIDEBAR_LINK_ACTIVE_CLASSES
      else
        SIDEBAR_LINK_INACTIVE_CLASSES
      end

      "#{SIDEBAR_LINK_BASE_CLASSES} #{state_classes}"
    end

    def js_admin_flash_classes(type)
      [ FLASH_BASE_CLASSES, FLASH_CLASSES.fetch(type.to_sym) ].join(" ")
    end

    def js_admin_pagination_link_classes
      PAGINATION_LINK_CLASSES
    end

    def js_admin_pagination_disabled_classes
      PAGINATION_DISABLED_CLASSES
    end

    def js_admin_pagination_status_classes
      PAGINATION_STATUS_CLASSES
    end

    def js_admin_stylesheet_link_tag(logical_name)
      return unless js_admin_asset_exists?("#{logical_name}.css")

      stylesheet_link_tag logical_name, "data-turbo-track": "reload"
    end

    def js_admin_hotwire_javascript_tags
      if respond_to?(:javascript_importmap_tags) && Rails.root.join("config/importmap.rb").exist?
        javascript_importmap_tags
      elsif js_admin_asset_exists?("application.js")
        javascript_include_tag "application", type: "module", "data-turbo-track": "reload"
      end
    end

    def js_admin_asset_exists?(logical_path)
      assets = Rails.application.assets

      if assets.respond_to?(:load_path)
        assets.load_path.find(logical_path).present?
      elsif Rails.application.assets_manifest
        Rails.application.assets_manifest.assets[logical_path].present?
      else
        false
      end
    rescue StandardError
      false
    end

    private

    def js_admin_field_name(form, field)
      "#{form.object_name}[#{field.name}]"
    end

    def js_admin_input_options(form, field, input_classes)
      js_admin_field_html_options(form, field, input_classes).merge(name: js_admin_field_name(form, field))
    end

    def js_admin_select_options(form, field)
      js_admin_field_html_options(form, field, js_admin_select_input_classes(form, field)).merge(include_blank: true)
    end

    def js_admin_field_html_options(form, field, input_classes)
      options = {
        id: js_admin_field_id(form, field),
        class: input_classes
      }

      if js_admin_field_errors(form.object, field).any?
        options[:aria] = {
          invalid: "true",
          describedby: js_admin_field_error_id(form, field)
        }
      end

      options
    end

    def js_admin_text_input_classes(form, field)
      js_admin_field_errors(form.object, field).any? ? TEXT_INPUT_ERROR_CLASSES : TEXT_INPUT_CLASSES
    end

    def js_admin_select_input_classes(form, field)
      js_admin_field_errors(form.object, field).any? ? SELECT_INPUT_ERROR_CLASSES : SELECT_INPUT_CLASSES
    end

    def js_admin_checkbox_input_classes(form, field)
      js_admin_field_errors(form.object, field).any? ? CHECKBOX_INPUT_ERROR_CLASSES : CHECKBOX_INPUT_CLASSES
    end

    def js_admin_field_value(form, field)
      before_type_cast_method = "#{field.name}_before_type_cast"

      if form.object.respond_to?(before_type_cast_method)
        form.object.public_send(before_type_cast_method)
      else
        form.object.public_send(field.name)
      end
    end

    def js_admin_formatted_field_value(form, field, format)
      value = js_admin_field_value(form, field)
      return value if value.blank? || !value.respond_to?(:strftime)

      value.strftime(format)
    end

    def js_admin_checkbox_checked?(form, field)
      ActiveModel::Type::Boolean.new.cast(js_admin_field_value(form, field))
    end

    def js_admin_sidebar_resources
      JSAdmin.resources.sort_by { |resource| resource.model_class.name }
    end

    def js_admin_resource_namespace(resource)
      resource.model_class.name.deconstantize
    end

    def js_admin_sidebar_resource_active?(resource)
      params[:model_id] == resource.model_id
    end
  end
end
