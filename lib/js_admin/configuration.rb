module JSAdmin
  class Configuration
    attr_accessor :included_models,
                  :excluded_models,
                  :records_per_page,
                  :association_limit,
                  :display_name_methods,
                  :basic_auth_username,
                  :basic_auth_password,
                  :basic_auth_realm

    def initialize
      @included_models = []
      @excluded_models = []
      @records_per_page = 10
      @association_limit = 100
      @display_name_methods = %i[name title email username id]
      @basic_auth_username = nil
      @basic_auth_password = nil
      @basic_auth_realm = "JSAdmin"
    end

    def include_models(*models)
      included_models.concat(normalize_model_names(models))
    end

    def exclude_models(*models)
      excluded_models.concat(normalize_model_names(models))
    end

    def basic_auth_enabled?
      basic_auth_username.to_s != "" && basic_auth_password.to_s != ""
    end

    private

    def normalize_model_names(models)
      models.flatten.map { |model| model.is_a?(Class) ? model.name : model.to_s }
    end
  end
end
