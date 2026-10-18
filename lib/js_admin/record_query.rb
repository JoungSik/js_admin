module JSAdmin
  class RecordQuery
    BOOLEAN_FILTER_VALUES = %w[true false].freeze
    LIKE_ESCAPE_CHARACTER = "\\"
    SORT_DIRECTIONS = %w[asc desc].freeze
    DEFAULT_SORT_DIRECTION = "asc"

    attr_reader :search_term, :filter_values

    def initialize(resource, search_term: nil, filter_values: {}, sort_column: nil, sort_direction: nil)
      @resource = resource
      @search_term = search_term.to_s.strip
      @filter_values = normalize_filter_values(filter_values)
      @requested_sort_column = sortable_column_name(sort_column)
      @requested_sort_direction = normalize_sort_direction(sort_direction)
    end

    def scope
      resource.model_class.all
        .then { |records| apply_search(records) }
        .then { |records| apply_filters(records) }
        .then { |records| apply_sort(records) }
    end

    def to_params
      condition_params.merge(sort_params)
    end

    def condition_params
      { q: search_term.presence, filters: filter_values.presence }.compact
    end

    def sort_params
      return {} unless requested_sort_column

      { sort: requested_sort_column, direction: requested_sort_direction }
    end

    def active?
      condition_params.any?
    end

    def sort_column
      current_sort&.first
    end

    def sort_direction
      current_sort&.last
    end

    private

    attr_reader :resource, :requested_sort_column, :requested_sort_direction

    def apply_search(records)
      return records if search_term.blank? || resource.search_fields.empty?

      pattern = "%#{resource.model_class.sanitize_sql_like(search_term, LIKE_ESCAPE_CHARACTER)}%"
      table = resource.model_class.arel_table
      condition = resource.search_fields
        .map { |field| table[field.name].matches(pattern, LIKE_ESCAPE_CHARACTER) }
        .reduce(:or)

      records.where(condition)
    end

    def apply_filters(records)
      filter_values.reduce(records) do |filtered_records, (column_name, value)|
        filtered_records.where(column_name => value)
      end
    end

    def apply_sort(records)
      primary_key = resource.model_class.primary_key
      primary_key = nil unless primary_key && resource.model_class.column_names.include?(primary_key)
      records = records.order(sort_column => sort_direction) if sort_column
      return records if primary_key.nil? || sort_column == primary_key

      records.order(primary_key => :desc)
    end

    def current_sort
      return [ requested_sort_column, requested_sort_direction ] if requested_sort_column

      configured_default_sort
    end

    def configured_default_sort
      column_name, direction = JSAdmin.configuration.default_sort_for(resource.model_class)
      return unless column_name

      unless resource.fields.any? { |field| field.name == column_name }
        raise ConfigurationError, I18n.t(
          "js_admin.configuration.errors.unknown_field",
          model: resource.model_class.name,
          field: column_name
        )
      end

      [ column_name, direction ]
    end

    def sortable_column_name(column_name)
      resource.list_fields.find { |field| field.name == column_name.to_s }&.name
    end

    def normalize_sort_direction(direction)
      SORT_DIRECTIONS.include?(direction.to_s) ? direction.to_s : DEFAULT_SORT_DIRECTION
    end

    def normalize_filter_values(raw_filter_values)
      filter_fields = resource.filter_fields.index_by(&:name)

      raw_filter_values.to_h.each_with_object({}) do |(column_name, value), normalized|
        field = filter_fields[column_name.to_s]
        next unless field && valid_filter_value?(field, value.to_s)

        normalized[field.name] = value.to_s
      end
    end

    def valid_filter_value?(field, value)
      case field.filter_kind
      when :boolean
        BOOLEAN_FILTER_VALUES.include?(value)
      when :enum
        field.enum_values.include?(value)
      when :association
        value.present?
      else
        false
      end
    end
  end
end
