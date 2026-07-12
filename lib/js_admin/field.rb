module JSAdmin
  class Field
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

    def editable?
      !primary_key? &&
        !timestamp? &&
        !inheritance_column? &&
        !readonly_attribute? &&
        !generated_column?
    end

    def input_kind
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

    def enum?
      enum_values.any?
    end

    def enum_values
      resource.model_class.defined_enums.fetch(name, {}).keys
    end

    def belongs_to_association
      @belongs_to_association ||= resource.model_class
        .reflect_on_all_associations(:belongs_to)
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
        "NULL"
      when true
        "true"
      when false
        "false"
      else
        value.to_s
      end
    end

    private

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
