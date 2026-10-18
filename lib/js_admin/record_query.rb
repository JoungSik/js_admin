module JSAdmin
  class RecordQuery
    BOOLEAN_FILTER_VALUES = %w[true false].freeze
    LIKE_ESCAPE_CHARACTER = "\\"

    attr_reader :search_term, :filter_values

    def initialize(resource, search_term: nil, filter_values: {})
      @resource = resource
      @search_term = search_term.to_s.strip
      @filter_values = normalize_filter_values(filter_values)
    end

    def scope
      resource.model_class.all
        .then { |records| apply_search(records) }
        .then { |records| apply_filters(records) }
    end

    def to_params
      { q: search_term.presence, filters: filter_values.presence }.compact
    end

    def active?
      to_params.any?
    end

    private

    attr_reader :resource

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
