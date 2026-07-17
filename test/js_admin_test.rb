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
