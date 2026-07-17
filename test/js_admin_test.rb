require "test_helper"
require "generators/js_admin/install/install_generator"

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

  test "configuration shows ten records per page by default" do
    assert_equal 10, JSAdmin::Configuration.new.records_per_page
  end

  test "resource model id keeps namespace boundaries" do
    model_class = Struct.new(:name).new("Ad::Place")

    assert_equal "ad--place", JSAdmin::Resource.new(model_class).model_id
  end
end
