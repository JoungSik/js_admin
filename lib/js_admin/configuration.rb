module JSAdmin
  class Configuration
    attr_accessor :included_models, :excluded_models, :records_per_page,
      :association_limit, :display_name_methods

    def initialize
      @included_models = []
      @excluded_models = []
      @records_per_page = 25
      @association_limit = 100
      @display_name_methods = %i[name title email username id]
    end

    def include_models(*models)
      included_models.concat(normalize_model_names(models))
    end

    def exclude_models(*models)
      excluded_models.concat(normalize_model_names(models))
    end

    private

    def normalize_model_names(models)
      models.flatten.map { |model| model.is_a?(Class) ? model.name : model.to_s }
    end
  end
end
