require "test_helper"

class ResourcesTest < ActionDispatch::IntegrationTest
  setup do
    JSAdmin.configure do |config|
      config.included_models = [ "Category", "Product" ]
      config.excluded_models = []
      config.records_per_page = 25
      config.basic_auth_username = nil
      config.basic_auth_password = nil
      config.basic_auth_realm = "JSAdmin"
      config.authenticate_with
      config.authorize_with
    end

    @category = Category.create!(name: "Books")
    @product = Product.create!(
      category: @category,
      name: "Practical Rails",
      description: "A compact Rails guide",
      price: 19.99,
      available: true,
      status: :published,
      released_on: Date.new(2026, 7, 9)
    )
  end

  teardown do
    Product.delete_all
    Category.delete_all

    JSAdmin.configure do |config|
      config.included_models = []
      config.excluded_models = []
      config.records_per_page = 25
      config.basic_auth_username = nil
      config.basic_auth_password = nil
      config.basic_auth_realm = "JSAdmin"
      config.authenticate_with
      config.authorize_with
      config.field_select_options = {}
    end
  end

  test "renders configured active record models in sidebar" do
    get "/admin"

    assert_response :success
    assert_select "main [data-js-admin-home]", 1
    assert_select "aside a", text: /Product/
    assert_select "aside a", text: /Category/
  end

  test "renders column based form inputs" do
    get "/admin/product/new"

    assert_response :success
    assert_select "turbo-frame#js_admin_content"
    assert_select 'input[name="product[name]"]'
    assert_select 'textarea[name="product[description]"]'
    assert_select 'input[type="number"][name="product[price]"]'
    assert_select 'input[type="checkbox"][name="product[available]"]'
    assert_select 'select[name="product[status]"]'
    assert_select 'select[name="product[category_id]"]'
  end

  test "renders configured select options for a column" do
    available_names = [ "Practical Rails" ]
    JSAdmin.configure do |config|
      config.select_options "Product", name: -> { available_names }
    end
    available_names += [ "Rails Testing" ]

    get "/admin/product/#{@product.id}/edit"

    assert_response :success
    assert_select 'select[name="product[name]"] option[value="Rails Testing"]'
    assert_select 'select[name="product[name]"] option[selected][value="Practical Rails"]'
  end

  test "creates a record through generic crud" do
    assert_difference "Product.count", 1 do
      post "/admin/product", params: {
        product: {
          category_id: @category.id,
          name: "New Rails",
          description: "Generated form",
          price: "29.90",
          available: "1",
          status: "draft",
          released_on: "2026-07-10"
        }
      }
    end

    created_product = Product.order(:id).last
    assert_redirected_to "/admin/product/#{created_product.id}"
    assert_equal "New Rails", created_product.name
    assert_equal "draft", created_product.status
  end

  test "renders validation errors inline in the form" do
    assert_no_difference "Product.count" do
      post "/admin/product", params: {
        product: {
          category_id: @category.id,
          name: "",
          description: "Missing name",
          price: "29.90",
          available: "1",
          status: "draft",
          released_on: "2026-07-10"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "[data-controller='js-admin-flash']", 0
    assert_select ".field_with_errors", 0
    assert_select "label[for='product_name']", text: "Name"
    assert_select "input[name='product[name]'][id='product_name'][aria-invalid='true'][aria-describedby='product_name_error']"
    assert_select "p#product_name_error", text: /can't be blank/
  end

  test "updates a record through generic crud" do
    patch "/admin/product/#{@product.id}", params: {
      product: {
        category_id: @category.id,
        name: "Updated Rails",
        description: @product.description,
        price: "39.50",
        available: "0",
        status: "draft",
        released_on: "2026-07-11"
      }
    }

    assert_redirected_to "/admin/product/#{@product.id}"
    assert_equal "Updated Rails", @product.reload.name
    assert_not @product.available
  end

  test "deletes a record through generic crud" do
    assert_difference "Product.count", -1 do
      delete "/admin/product/#{@product.id}"
    end

    assert_redirected_to "/admin/product"
  end

  test "deletes a record through turbo stream updates" do
    assert_difference "Product.count", -1 do
      delete "/admin/product/#{@product.id}", headers: {
        "Accept" => "text/vnd.turbo-stream.html"
      }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_includes response.body, 'target="js_admin_flash"'
    assert_includes response.body, 'target="js_admin_content_body"'
    assert_includes response.body, "Product was deleted."
  end

  test "renders view edit and delete row actions" do
    get "/admin/product"

    assert_response :success
    assert_select "turbo-frame#js_admin_content"
    assert_select "a", text: "View"
    assert_select "a", text: "Edit"
    assert_select "button", text: "Delete"
    assert_select "a", text: "Open", count: 0
  end

  test "renders compact pagination controls" do
    JSAdmin.configure do |config|
      config.records_per_page = 1
    end

    2.times do |index|
      Product.create!(
        category: @category,
        name: "Paginated Product #{index + 1}",
        description: "Pagination fixture",
        price: 9.99,
        available: true,
        status: :draft,
        released_on: Date.new(2026, 7, 12)
      )
    end

    get "/admin/product"

    assert_response :success
    assert_select "nav[aria-label='Pagination']"
    assert_select "div", text: /Page 1 of 3/, count: 0
    assert_select "span[aria-disabled='true']", text: "First"
    assert_select "span[aria-disabled='true']", text: "Previous"
    assert_select "span[aria-current='page'][aria-label='Page 1 of 3']", text: "1 / 3"
    assert_select "a[href='/admin/product?page=2']", text: "Next"
    assert_select "a[href='/admin/product?page=3']", text: "Last"
    assert_select "nav[aria-label='Pagination']", text: /\.\.\./, count: 0
  end

  test "requires basic auth when configured" do
    JSAdmin.configure do |config|
      config.basic_auth_username = "admin"
      config.basic_auth_password = "secret"
    end

    get "/admin"

    assert_response :unauthorized
    assert_includes response.headers["WWW-Authenticate"], 'Basic realm="JSAdmin"'
  end

  test "allows requests with valid basic auth credentials" do
    JSAdmin.configure do |config|
      config.basic_auth_username = "admin"
      config.basic_auth_password = "secret"
    end

    get "/admin", headers: {
      "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret")
    }

    assert_response :success
    assert_select "aside a", text: /Product/
  end

  test "requires authentication through host callback when configured" do
    JSAdmin.configure do |config|
      config.authenticate_with do
        head :unauthorized unless request.headers["X-JSAdmin-User"] == "admin"
      end
    end

    get "/admin"
    assert_response :unauthorized

    get "/admin", headers: { "X-JSAdmin-User" => "admin" }
    assert_response :success
  end

  test "returns forbidden when host authorization callback denies access" do
    JSAdmin.configure do |config|
      config.authenticate_with { request }
      config.authorize_with { request.headers["X-JSAdmin-Role"] == "admin" }
    end

    get "/admin", headers: { "X-JSAdmin-Role" => "member" }
    assert_response :forbidden

    get "/admin", headers: { "X-JSAdmin-Role" => "admin" }
    assert_response :success
  end

  test "renders js_admin interface using current locale" do
    I18n.with_locale(:ko) do
      get "/admin/product"
    end

    assert_response :success
    assert_select "a", text: "홈"
    assert_select "th", text: "작업"
    assert_select "a", text: "보기"
    assert_select "a", text: "편집"
    assert_select "button", text: "삭제"
    assert_select "nav[aria-label='페이지 탐색']"
    assert_select "span", text: "참"
  end

  test "renders localized crud notice" do
    I18n.with_locale(:ko) do
      delete "/admin/product/#{@product.id}", headers: {
        "Accept" => "text/vnd.turbo-stream.html"
      }
    end

    assert_response :success
    assert_includes response.body, "Product 레코드를 삭제했습니다."
  end
end
