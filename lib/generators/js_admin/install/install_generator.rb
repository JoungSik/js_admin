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
