require "js_admin/version"

require "importmap-rails"
require "stimulus-rails"
require "tailwindcss-rails"
require "turbo-rails"

require "js_admin/configuration"
require "js_admin/field"
require "js_admin/registry"
require "js_admin/resource"
require "js_admin/engine"

module JSAdmin
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
      Registry.reset!
    end

    def resources
      Registry.resources
    end

    def resource_for!(model_id)
      Registry.resource_for!(model_id)
    end
  end
end
