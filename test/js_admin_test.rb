require "test_helper"
require "generators/js_admin/install/install_generator"
require "fileutils"
require "tmpdir"

class JSAdminTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert JSAdmin::VERSION
  end

  test "install generator keeps public js_admin namespace" do
    assert_equal "js_admin:install", JSAdmin::Generators::InstallGenerator.namespace
  end

  test "install generator mounts at admin by default" do
    assert_equal "/admin", JSAdmin::Generators::InstallGenerator.class_options[:path].default
  end

  test "install generator creates a configuration initializer" do
    destination = Dir.mktmpdir("js_admin_generator")
    FileUtils.mkdir_p(File.join(destination, "config"))
    File.write(File.join(destination, "config/routes.rb"), <<~RUBY)
      Rails.application.routes.draw do
      end
    RUBY
    File.write(File.join(destination, "config/importmap.rb"), <<~RUBY)
      pin "@hotwired/stimulus", to: "stimulus.min.js"
    RUBY

    JSAdmin::Generators::InstallGenerator.start([], destination_root: destination)
    initializer = File.read(File.join(destination, "config/initializers/js_admin.rb"))
    importmap = File.read(File.join(destination, "config/importmap.rb"))

    assert_includes initializer, "JSAdmin.configure do |config|"
    assert_includes initializer, "config.records_per_page = 10"
    assert_includes initializer, "config.basic_auth_username"
    assert_includes initializer, "config.authenticate_with"
    assert_includes initializer, "config.authorize_with"
    assert_includes importmap, 'pin "@hotwired/turbo-rails", to: "turbo.min.js"'
    assert_equal 1, importmap.scan(/pin "@hotwired\/stimulus"/).size
    assert_includes importmap, 'pin "js_admin", to: "js_admin/application.js", preload: true'
    assert_includes importmap, 'pin "js_admin/controllers/theme_controller", to: "js_admin/controllers/theme_controller.js", preload: true'
    assert_includes importmap, 'pin "js_admin/controllers/flash_controller", to: "js_admin/controllers/flash_controller.js", preload: true'
  ensure
    FileUtils.rm_rf(destination) if destination
  end

  test "configuration shows ten records per page by default" do
    assert_equal 10, JSAdmin::Configuration.new.records_per_page
  end

  test "configuration selects callback authentication" do
    configuration = JSAdmin::Configuration.new
    configuration.authenticate_with { request }

    assert_equal :callback, configuration.authentication_strategy
    assert_same configuration, configuration.validate!
  end

  test "configuration rejects incomplete basic auth with localized error" do
    configuration = JSAdmin::Configuration.new
    configuration.basic_auth_username = "admin"

    error = I18n.with_locale(:ko) do
      assert_raises(JSAdmin::ConfigurationError) { configuration.validate! }
    end

    assert_equal "Basic Auth username과 password를 모두 설정해야 합니다.", error.message
  end

  test "configuration rejects multiple authentication strategies" do
    configuration = JSAdmin::Configuration.new
    configuration.basic_auth_username = "admin"
    configuration.basic_auth_password = "secret"
    configuration.authenticate_with { request }

    error = assert_raises(JSAdmin::ConfigurationError) { configuration.validate! }

    assert_equal(
      "Basic Auth and authenticate_with cannot be configured at the same time.",
      error.message
    )
  end

  test "configuration rejects authorization callback without authentication callback" do
    configuration = JSAdmin::Configuration.new
    configuration.authorize_with { true }

    error = assert_raises(JSAdmin::ConfigurationError) { configuration.validate! }

    assert_equal "authorize_with requires authenticate_with.", error.message
  end

  test "engine controller inherits from host application controller" do
    assert_operator JSAdmin::ApplicationController, :<, ::ApplicationController
  end

  test "configuration stores select options by model name and field name" do
    configuration = JSAdmin::Configuration.new
    status_options = -> { %w[draft published] }

    configuration.select_options Product, name: status_options

    assert_same status_options, configuration.select_options_for("Product", :name)
    assert_nil configuration.select_options_for(Product, :description)
  end

  test "javascript registers controllers with the host stimulus application when present" do
    javascript = JSAdmin::Engine.root.join("app/assets/javascripts/js_admin/application.js").read
    theme_controller = JSAdmin::Engine.root.join("app/assets/javascripts/js_admin/controllers/theme_controller.js").read
    flash_controller = JSAdmin::Engine.root.join("app/assets/javascripts/js_admin/controllers/flash_controller.js").read

    assert_includes javascript, 'import "@hotwired/turbo-rails"'
    assert_includes javascript, 'import ThemeController from "js_admin/controllers/theme_controller"'
    assert_includes javascript, 'import FlashController from "js_admin/controllers/flash_controller"'
    assert_includes javascript, "window.Stimulus || window.JSAdminStimulus || Application.start()"
    assert_includes javascript, 'application.register("js-admin-theme", ThemeController)'
    assert_includes javascript, 'application.register("js-admin-flash", FlashController)'
    assert_includes theme_controller, "THEME_COOKIE_NAME"
    assert_includes theme_controller, "document.cookie"
    assert_includes flash_controller, "this.element.classList.add"
  end

  test "resource model id keeps namespace boundaries" do
    model_class = Struct.new(:name).new("Ad::Place")

    assert_equal "ad--place", JSAdmin::Resource.new(model_class).model_id
  end
end
