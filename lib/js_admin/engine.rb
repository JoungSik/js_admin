module JSAdmin
  class Engine < ::Rails::Engine
    initializer "js_admin.inflections", before: :set_autoload_paths do
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.acronym "JS"
      end
    end

    isolate_namespace JSAdmin

    config.to_prepare do
      JSAdmin::Registry.reset!
    end
  end
end
