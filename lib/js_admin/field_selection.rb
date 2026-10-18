module JSAdmin
  class FieldSelection
    DEFAULT_LIST_COLUMN_LIMIT = 6

    def initialize(resource)
      @resource = resource
    end

    def fields_for(screen)
      validate_hidden_column_names!
      configured_column_names = settings[screen]

      if configured_column_names
        configured_fields(screen, configured_column_names).reject { |field| hidden?(field) }
      else
        default_fields(screen)
      end
    end

    private

    attr_reader :resource

    def settings
      JSAdmin.configuration.field_settings_for(resource.model_class)
    end

    def hidden_column_names
      settings.fetch(:hidden, [])
    end

    def validate_hidden_column_names!
      hidden_column_names.each { |column_name| find_field!(column_name) }
    end

    def configured_fields(screen, column_names)
      column_names.map do |column_name|
        field = find_field!(column_name)
        raise_configuration_error(:non_editable_form_field, column_name) if screen == :form && !field.editable?
        raise_configuration_error(:non_searchable_field, column_name) if screen == :search && !field.searchable?

        field
      end
    end

    def default_fields(screen)
      case screen
      when :list
        default_list_fields
      when :show
        default_visible(resource.fields)
      when :form
        default_visible(resource.editable_fields)
      when :search
        default_visible(resource.fields).select(&:searchable?)
      end
    end

    def default_list_fields
      visible_fields = default_visible(resource.fields).reject(&:timestamp?)
      id_field = visible_fields.find(&:primary_key?)
      selected_fields = visible_fields.reject(&:primary_key?).first(DEFAULT_LIST_COLUMN_LIMIT)

      [ id_field, *selected_fields ].compact
    end

    def default_visible(fields)
      fields.reject { |field| hidden?(field) || hidden_by_filter?(field) }
    end

    def hidden?(field)
      hidden_column_names.include?(field.name)
    end

    def hidden_by_filter?(field)
      JSAdmin.configuration.hide_filtered_columns && field.filtered?
    end

    def find_field!(column_name)
      resource.fields.find { |field| field.name == column_name } ||
        raise_configuration_error(:unknown_field, column_name)
    end

    def raise_configuration_error(error_key, column_name)
      raise ConfigurationError, I18n.t(
        "js_admin.configuration.errors.#{error_key}",
        model: resource.model_class.name,
        field: column_name
      )
    end
  end
end
