module JSAdmin
  class Configuration
    attr_accessor :included_models,
                  :excluded_models,
                  :records_per_page,
                  :association_limit,
                  :display_name_methods,
                  :field_select_options,
                  :basic_auth_username,
                  :basic_auth_password,
                  :basic_auth_realm

    attr_reader :authentication_callback, :authorization_callback

    def initialize
      @included_models = []
      @excluded_models = []
      @records_per_page = 10
      @association_limit = 100
      @display_name_methods = %i[name title email username id]
      @field_select_options = {}
      @basic_auth_username = nil
      @basic_auth_password = nil
      @basic_auth_realm = "JSAdmin"
      @authentication_callback = nil
      @authorization_callback = nil
    end

    def include_models(*models)
      included_models.concat(normalize_model_names(models))
    end

    def exclude_models(*models)
      excluded_models.concat(normalize_model_names(models))
    end

    def select_options(model, **options_by_field)
      model_options = field_select_options[normalize_model_names([ model ]).first] ||= {}
      model_options.merge!(options_by_field.transform_keys(&:to_s))
    end

    def select_options_for(model, field_name)
      field_select_options.dig(normalize_model_names([ model ]).first, field_name.to_s)
    end

    def basic_auth_enabled?
      basic_auth_username_configured? && basic_auth_password_configured?
    end

    def authenticate_with(&callback)
      @authentication_callback = callback
    end

    def authorize_with(&callback)
      @authorization_callback = callback
    end

    def authentication_strategy
      validate!

      return :callback if authentication_callback
      return :basic_auth if basic_auth_enabled?

      :none
    end

    def validate!
      validate_basic_auth_credentials!
      validate_authentication_strategy!
      validate_authorization_callback!

      self
    end

    private

    def validate_basic_auth_credentials!
      return if basic_auth_username_configured? == basic_auth_password_configured?

      raise ConfigurationError, I18n.t("js_admin.configuration.errors.incomplete_basic_auth")
    end

    def validate_authentication_strategy!
      return unless basic_auth_enabled? && authentication_callback

      raise ConfigurationError, I18n.t("js_admin.configuration.errors.multiple_authentication_strategies")
    end

    def validate_authorization_callback!
      return unless authorization_callback && !authentication_callback

      raise ConfigurationError, I18n.t("js_admin.configuration.errors.authorization_without_authentication")
    end

    def basic_auth_username_configured?
      basic_auth_username.to_s != ""
    end

    def basic_auth_password_configured?
      basic_auth_password.to_s != ""
    end

    def normalize_model_names(models)
      models.flatten.map { |model| model.is_a?(Class) ? model.name : model.to_s }
    end
  end
end
