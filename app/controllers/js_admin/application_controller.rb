require "digest"

module JSAdmin
  class ApplicationController < ActionController::Base
    before_action :authenticate_basic_auth

    private

    def authenticate_basic_auth
      return unless JSAdmin.configuration.basic_auth_enabled?

      authenticate_or_request_with_http_basic(basic_auth_realm) do |username, password|
        secure_compare(username, JSAdmin.configuration.basic_auth_username) &&
          secure_compare(password, JSAdmin.configuration.basic_auth_password)
      end
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
