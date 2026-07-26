require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  SidebarModelClass = Struct.new(:name)
  SidebarResource = Struct.new(:model_class, :model_id)

  setup do
    JSAdmin.configure do |config|
      config.included_models = [ "Category", "Product" ]
      config.excluded_models = []
      config.basic_auth_username = nil
      config.basic_auth_password = nil
      config.basic_auth_realm = "JSAdmin"
      config.authenticate_with
      config.authorize_with
    end
  end

  teardown do
    JSAdmin.configure do |config|
      config.included_models = []
      config.excluded_models = []
      config.basic_auth_username = nil
      config.basic_auth_password = nil
      config.basic_auth_realm = "JSAdmin"
      config.authenticate_with
      config.authorize_with
    end
  end

  test "renders empty home content with sidebar model navigation" do
    get "/admin"

    assert_response :success
    assert_select "body[data-controller='js-admin-theme']"
    assert_select "script[type='importmap']", text: /"js_admin"/
    assert_select "script[type='importmap']", text: %r{"js_admin/controllers/theme_controller"}
    assert_select "script[type='importmap']", text: %r{"js_admin/controllers/flash_controller"}
    assert_select "script[type='module']", text: /import "js_admin"/
    assert_no_match "localStorage.getItem", response.body
    assert_select "turbo-frame#js_admin_content[data-turbo-action='advance']"
    assert_select "main [data-js-admin-home]", 1
    assert_select "main a", 0
    assert_select "aside [data-js-admin-sidebar-link='category'][data-turbo-frame='js_admin_content'][data-turbo-action='advance']", text: "Category"
    assert_select "aside [data-js-admin-sidebar-link='product'][data-turbo-frame='js_admin_content'][data-turbo-action='advance']", text: "Product"
    assert_select "aside [data-js-admin-theme-target='toggle'][data-action='js-admin-theme#toggle']", text: /Theme/
    assert_select "header [data-js-admin-theme-target='toggle']", 0
    assert_select "header.fixed.top-0"
    assert_select "div.pt-16"
    assert_select "aside.lg\\:top-16"
  end

  test "renders saved dark theme without inline theme javascript" do
    get "/admin", headers: {
      "Cookie" => "js_admin_theme=dark"
    }

    assert_response :success
    assert_select "html.dark"
    assert_no_match "localStorage.getItem", response.body
  end

  test "groups namespaced resources in sidebar dropdowns" do
    with_sidebar_resources([
      sidebar_resource("Place", "place"),
      sidebar_resource("Ad::Place", "ad--place")
    ]) do
      get "/admin"
    end

    assert_response :success
    assert_select "aside [data-js-admin-sidebar-link='place'][data-turbo-frame='js_admin_content']", text: "Place"
    assert_select "aside details summary", text: /Ad/
    assert_select "aside details [data-js-admin-sidebar-link='ad--place'][data-turbo-frame='js_admin_content']", text: "Place"
  end

  test "renders frame content for turbo frame requests" do
    get "/admin/product", headers: {
      "Turbo-Frame" => "js_admin_content"
    }

    assert_response :success
    assert_select "turbo-frame#js_admin_content"
    assert_select "#js_admin_content_body"
    assert_select "h1", text: "Product"
  end

  private

  def sidebar_resource(class_name, model_id)
    SidebarResource.new(SidebarModelClass.new(class_name), model_id)
  end

  def with_sidebar_resources(resources)
    original_resources_method = JSAdmin.method(:resources)
    JSAdmin.define_singleton_method(:resources) { resources }

    yield
  ensure
    JSAdmin.define_singleton_method(:resources, original_resources_method)
  end
end
