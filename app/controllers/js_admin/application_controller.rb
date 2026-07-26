require "digest"

module JSAdmin
  class ApplicationController < ::ApplicationController
    before_action :authenticate_js_admin
    before_action :authorize_js_admin

    private

    def authenticate_js_admin
      case JSAdmin.configuration.authentication_strategy
      when :basic_auth
        authenticate_basic_auth
      when :callback
        instance_exec(&JSAdmin.configuration.authentication_callback)
      end
    end

    def authenticate_basic_auth
      authenticate_or_request_with_http_basic(basic_auth_realm) do |username, password|
        secure_compare(username, JSAdmin.configuration.basic_auth_username) &&
          secure_compare(password, JSAdmin.configuration.basic_auth_password)
      end
    end

    def authorize_js_admin
      callback = JSAdmin.configuration.authorization_callback
      return unless callback
      return if instance_exec(&callback)

      head :forbidden
    end

    def basic_auth_realm
      realm = JSAdmin.configuration.basic_auth_realm.to_s
      return "JSAdmin" if realm.empty?

      realm
    end

    def secure_compare(provided_value, expected_value)
      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided_value.to_s),
        Digest::SHA256.hexdigest(expected_value.to_s)
      )
    end
  end
end
