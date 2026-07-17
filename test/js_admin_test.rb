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

    JSAdmin::Generators::InstallGenerator.start([], destination_root: destination)
    initializer = File.read(File.join(destination, "config/initializers/js_admin.rb"))

    assert_includes initializer, "JSAdmin.configure do |config|"
    assert_includes initializer, "config.records_per_page = 10"
    assert_includes initializer, "config.basic_auth_username"
  ensure
    FileUtils.rm_rf(destination) if destination
  end

  test "configuration shows ten records per page by default" do
    assert_equal 10, JSAdmin::Configuration.new.records_per_page
  end

  test "resource model id keeps namespace boundaries" do
    model_class = Struct.new(:name).new("Ad::Place")

    assert_equal "ad--place", JSAdmin::Resource.new(model_class).model_id
  end
end
