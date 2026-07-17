module JSAdmin
  class Resource
    attr_reader :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def model_id
      model_class.name.underscore.gsub("/", "--")
    end

    def label
      model_class.model_name.human(count: 2)
    end

    def singular_label
      model_class.model_name.human
    end

    def param_key
      model_class.model_name.param_key
    end

    def fields
      @fields ||= model_class.columns.map { |column| Field.new(self, column) }
    end

    def editable_fields
      fields.select(&:editable?)
    end

    def list_fields
      visible_fields = fields.reject(&:timestamp?)
      id_field = visible_fields.find(&:primary_key?)
      selected_fields = visible_fields.reject(&:primary_key?).first(6)

      [ id_field, *selected_fields ].compact
    end

    def records(page:)
      page_number = [ page.to_i, 1 ].max
      model_class.all
        .then { |scope| ordered_scope(scope) }
        .limit(records_per_page)
        .offset((page_number - 1) * records_per_page)
    end

    def count
      model_class.count
    end

    def total_pages(total_count: count)
      [ (total_count.to_f / records_per_page).ceil, 1 ].max
    end

    def find(record_id)
      model_class.find(record_id)
    end

    def new_record(attributes = {})
      model_class.new(attributes)
    end

    def display_name(record)
      display_method = JSAdmin.configuration.display_name_methods.find do |method_name|
        record.respond_to?(method_name) && record.public_send(method_name).present?
      end

      return record.public_send(display_method).to_s if display_method

      "#{singular_label} ##{record.id}"
    end

    def next_page?(page)
      page.to_i < total_pages
    end

    def previous_page?(page)
      page.to_i > 1
    end

    private

    def ordered_scope(scope)
      primary_key = model_class.primary_key
      return scope unless primary_key && model_class.column_names.include?(primary_key)

      scope.order(primary_key => :desc)
    end

    def records_per_page
      [ JSAdmin.configuration.records_per_page.to_i, 1 ].max
    end
  end
end
