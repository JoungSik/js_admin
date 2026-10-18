module JSAdmin
  class Field
    SEARCHABLE_TYPES = %i[string text].freeze

    attr_reader :resource, :column

    def initialize(resource, column)
      @resource = resource
      @column = column
    end

    def name
      column.name
    end

    def human_name
      resource.model_class.human_attribute_name(name)
    end

    def type
      column.type
    end

    def primary_key?
      name == resource.model_class.primary_key
    end

    def timestamp?
      %w[created_at updated_at].include?(name)
    end

    def filtered?
      parameter_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      probe_value = +"js_admin"

      parameter_filter.filter(name => probe_value)[name] != probe_value
    end

    def editable?
      !primary_key? &&
        !timestamp? &&
        !inheritance_column? &&
        !readonly_attribute? &&
        !generated_column?
    end

    def input_kind
      return :configured_select if configured_select?
      return :association_select if belongs_to_association
      return :enum_select if enum?

      case type
      when :text
        :text_area
      when :boolean
        :check_box
      when :integer, :bigint, :float, :decimal
        :number_field
      when :date
        :date_field
      when :datetime
        :datetime_field
      when :time
        :time_field
      else
        :text_field
      end
    end

    def searchable?
      SEARCHABLE_TYPES.include?(type)
    end

    def filter_kind
      return :association if belongs_to_association
      return :enum if enum?

      :boolean if type == :boolean
    end

    def filterable?
      !filter_kind.nil?
    end

    def filter_options
      case filter_kind
      when :association
        association_options
      when :enum
        enum_values
      when :boolean
        RecordQuery::BOOLEAN_FILTER_VALUES.map { |value| [ I18n.t("js_admin.values.#{value}"), value ] }
      else
        []
      end
    end

    def enum?
      enum_values.any?
    end

    def enum_values
      resource.model_class.defined_enums.fetch(name, {}).keys
    end

    def configured_select?
      !configured_select_source.nil?
    end

    def configured_select_values
      source = configured_select_source
      Array(source.respond_to?(:call) ? source.call : source)
    end

    def belongs_to_association
      @belongs_to_association ||= resource.model_class
                                          .reflect_on_all_associations(:belongs_to)
                                          .reject(&:polymorphic?)
                                          .find { |association| association.foreign_key.to_s == name }
    rescue NameError
      nil
    end

    def association_options
      association = belongs_to_association
      return [] unless association

      association_resource = Resource.new(association.klass)
      association.klass
                 .limit(JSAdmin.configuration.association_limit)
                 .map { |record| [ association_resource.display_name(record), record.id ] }
    rescue ActiveRecord::ActiveRecordError, NameError
      []
    end

    def number_step
      %i[float decimal].include?(type) ? "any" : 1
    end

    def value_for(record)
      record.public_send(name)
    end

    def formatted_value(record)
      value = value_for(record)

      case value
      when nil
        I18n.t("js_admin.values.null")
      when true
        I18n.t("js_admin.values.true")
      when false
        I18n.t("js_admin.values.false")
      else
        value.to_s
      end
    end

    private

    def configured_select_source
      JSAdmin.configuration.select_options_for(resource.model_class, name)
    end

    def inheritance_column?
      name == resource.model_class.inheritance_column
    end

    def readonly_attribute?
      resource.model_class.readonly_attributes.include?(name)
    end

    def generated_column?
      column.respond_to?(:generated?) && column.generated?
    end
  end
end
