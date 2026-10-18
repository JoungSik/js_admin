require "rails/generators"

module JSAdmin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      IMPORTMAP_PINS = {
        "@hotwired/turbo-rails" => 'pin "@hotwired/turbo-rails", to: "turbo.min.js"',
        "@hotwired/stimulus" => 'pin "@hotwired/stimulus", to: "stimulus.min.js"',
        "js_admin" => 'pin "js_admin", to: "js_admin/application.js", preload: true',
        "js_admin/controllers/theme_controller" => 'pin "js_admin/controllers/theme_controller", to: "js_admin/controllers/theme_controller.js", preload: true',
        "js_admin/controllers/flash_controller" => 'pin "js_admin/controllers/flash_controller", to: "js_admin/controllers/flash_controller.js", preload: true'
      }.freeze

      namespace "js_admin:install"

      class_option :path,
                   type: :string,
                   default: "/admin",
                   desc: I18n.t("js_admin.generator.options.path")

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

            # Render a column as a select. Callables are evaluated on every form render.
            # config.select_options "Post", category: -> { Category.pluck(:name) }

            # Choose visible columns per screen. Columns matching filter_parameters are hidden unless listed.
            # config.fields "User", list: %i[id name email], form: %i[name email], search: %i[name email], hidden: %i[api_token]
            # config.default_sort "Post", :published_at, :desc
            # config.hide_filtered_columns = true

            # Basic Auth is disabled unless both username and password are present.
            # config.basic_auth_username = ENV["JS_ADMIN_BASIC_AUTH_USERNAME"]
            # config.basic_auth_password = ENV["JS_ADMIN_BASIC_AUTH_PASSWORD"]
            # config.basic_auth_realm = "JSAdmin"

            # Or delegate authentication and authorization to the host application.
            # config.authenticate_with { authenticate_user! }
            # config.authorize_with { current_user&.admin? }
          end
        RUBY
      end

      def pin_importmap_modules
        importmap_path = application_path("config/importmap.rb")

        unless File.exist?(importmap_path)
          say_status :warning, I18n.t("js_admin.generator.warnings.importmap_missing"), :yellow
          return
        end

        importmap = File.read(importmap_path)
        missing_pins = IMPORTMAP_PINS.filter_map do |name, line|
          line unless importmap.match?(/^\s*pin\s+["']#{Regexp.escape(name)}["']/)
        end

        return if missing_pins.empty?

        append_to_file importmap_path, "\n#{missing_pins.join("\n")}\n"
      end

      def import_tailwind_engine_styles
        tailwind_entrypoint = application_path("app/assets/tailwind/application.css")
        return unless File.exist?(tailwind_entrypoint)

        import_line = '@import "../builds/tailwind/js_admin";'
        return if File.read(tailwind_entrypoint).include?(import_line)

        append_to_file tailwind_entrypoint, "\n#{import_line}\n"
      end

      private

      def application_path(relative_path)
        File.join(destination_root, relative_path)
      end
    end
  end
end
