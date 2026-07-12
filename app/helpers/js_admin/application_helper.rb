module JSAdmin
  module ApplicationHelper
    TEXT_INPUT_CLASSES = "w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-950 shadow-sm focus:border-sky-500 focus:outline-none focus:ring-2 focus:ring-sky-200"
    SELECT_INPUT_CLASSES = "w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-950 shadow-sm focus:border-sky-500 focus:outline-none focus:ring-2 focus:ring-sky-200"
    CHECKBOX_INPUT_CLASSES = "h-4 w-4 rounded border-slate-300 text-sky-600 focus:ring-sky-500"

    def js_admin_field_input(form, field)
      case field.input_kind
      when :text_area
        form.text_area(field.name, rows: 5, class: TEXT_INPUT_CLASSES)
      when :check_box
        tag.div(class: "flex h-10 items-center") do
          form.check_box(field.name, class: CHECKBOX_INPUT_CLASSES)
        end
      when :number_field
        form.number_field(field.name, step: field.number_step, class: TEXT_INPUT_CLASSES)
      when :date_field
        form.date_field(field.name, class: TEXT_INPUT_CLASSES)
      when :datetime_field
        form.datetime_field(field.name, class: TEXT_INPUT_CLASSES)
      when :time_field
        form.time_field(field.name, class: TEXT_INPUT_CLASSES)
      when :enum_select
        form.select(field.name, field.enum_values, { include_blank: true }, class: SELECT_INPUT_CLASSES)
      when :association_select
        form.select(field.name, field.association_options, { include_blank: true }, class: SELECT_INPUT_CLASSES)
      else
        form.text_field(field.name, class: TEXT_INPUT_CLASSES)
      end
    end

    def js_admin_table_value(field, record)
      value = field.formatted_value(record)
      classes = value == "NULL" ? "text-slate-400" : "text-slate-700"

      tag.span(truncate(value, length: 80), class: classes)
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
  end
end
