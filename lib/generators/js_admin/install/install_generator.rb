require "rails/generators"

module JSAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      namespace "js_admin:install"

      class_option :path,
                   type: :string,
                   default: "/admin",
                   desc: "Mount path for JSAdmin"

      def mount_engine
        route %(mount JSAdmin::Engine => "#{options[:path]}")
      end

      def create_initializer
        create_file "config/initializers/js_admin.rb", <<~RUBY
          JSAdmin.configure do |config|
            # Limit visible models. When empty, JSAdmin exposes every concrete Active Record model.
            # config.include_models User, Post
            # config.exclude_models AuditLog

            # UI pagination and association select limits.
            # config.records_per_page = 10
            # config.association_limit = 100

            # Methods tried in order when displaying records in labels and associations.
            # config.display_name_methods = %i[name title email username id]

            # Basic Auth is disabled unless both username and password are present.
            # config.basic_auth_username = ENV["JS_ADMIN_BASIC_AUTH_USERNAME"]
            # config.basic_auth_password = ENV["JS_ADMIN_BASIC_AUTH_PASSWORD"]
            # config.basic_auth_realm = "JSAdmin"
          end
        RUBY
      end

      def import_tailwind_engine_styles
        tailwind_entrypoint = Rails.root.join("app/assets/tailwind/application.css")
        return unless tailwind_entrypoint.exist?

        import_line = '@import "../builds/tailwind/js_admin";'
        return if tailwind_entrypoint.read.include?(import_line)

        append_to_file tailwind_entrypoint, "\n#{import_line}\n"
      end
    end
  end
end
