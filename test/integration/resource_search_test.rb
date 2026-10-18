require "test_helper"

class ResourceSearchTest < ActionDispatch::IntegrationTest
  setup do
    reset_configuration
    JSAdmin.configure do |config|
      config.included_models = [ "Category", "Product", "User" ]
    end

    @books = Category.create!(name: "Books")
    @tools = Category.create!(name: "Tools")
    @rails_book = Product.create!(category: @books, name: "Practical Rails", description: "Guide", available: true, status: :published)
    @ruby_book = Product.create!(category: @books, name: "Ruby Testing", description: "Minitest", available: false, status: :draft)
    @hammer = Product.create!(category: @tools, name: "Hammer", description: "100% steel", available: true, status: :draft)
  end

  teardown do
    User.delete_all
    Product.delete_all
    Category.delete_all
    reset_configuration
  end

  test "renders search input and filter selects for list columns" do
    get "/admin/product"

    assert_response :success
    assert_select 'form[method="get"][action="/admin/product"]' do
      assert_select 'input[type="search"][name="q"]'
      assert_select 'select[name="filters[available]"]'
      assert_select 'select[name="filters[category_id]"] option[value=?]', @tools.id.to_s
      assert_select 'select[name="filters[status]"] option[value="draft"]'
    end
  end

  test "searches string and text columns" do
    get "/admin/product", params: { q: "minitest" }

    assert_response :success
    assert_includes response.body, "Ruby Testing"
    assert_not_includes response.body, "Practical Rails"
    assert_includes response.body, "1 record"
    assert_select 'input[name="q"][value="minitest"]'
  end

  test "escapes like wildcards in search terms" do
    get "/admin/product", params: { q: "%" }

    assert_includes response.body, "Hammer"
    assert_not_includes response.body, "Practical Rails"
  end

  test "filters by enum boolean and association columns" do
    get "/admin/product", params: { filters: { status: "draft", available: "true", category_id: @tools.id } }

    assert_response :success
    assert_includes response.body, "Hammer"
    assert_not_includes response.body, "Ruby Testing"
    assert_not_includes response.body, "Practical Rails"
    assert_select 'select[name="filters[status]"] option[selected][value="draft"]'
  end

  test "ignores invalid filter values and columns" do
    get "/admin/product", params: { filters: { status: "archived", available: "maybe", name: "Hammer" } }

    assert_response :success
    assert_includes response.body, "3 records"
  end

  test "ignores malformed search parameters" do
    get "/admin/product", params: { q: [ "Hammer" ], filters: "draft" }

    assert_response :success
    assert_includes response.body, "3 records"
  end

  test "does not search filtered columns by default" do
    User.create!(name: "Admin", email: "admin@example.com", api_token: "secret-token")

    get "/admin/user", params: { q: "example.com" }

    assert_includes response.body, "0 records"
  end

  test "searches configured columns" do
    User.create!(name: "Admin", email: "admin@example.com")
    JSAdmin.configure do |config|
      config.fields "User", search: %i[email]
    end

    get "/admin/user", params: { q: "example.com" }

    assert_includes response.body, "1 record"
  end

  test "keeps search and filters in pagination links" do
    JSAdmin.configure do |config|
      config.records_per_page = 1
    end

    get "/admin/product", params: { q: "a", filters: { available: "true" } }

    assert_response :success
    assert_select "nav a[href=?]", "/admin/product?filters%5Bavailable%5D=true&page=2&q=a"
  end

  test "keeps search and filters after deleting through turbo stream" do
    delete "/admin/product/#{@ruby_book.id}", params: { q: "rails", page: 1 }, headers: {
      "Accept" => "text/vnd.turbo-stream.html"
    }

    assert_response :success
    assert_includes response.body, "Practical Rails"
    assert_not_includes response.body, "Hammer"
  end

  test "renders delete buttons with current list parameters" do
    get "/admin/product", params: { q: "rails" }

    assert_select "form[action=?]", "/admin/product/#{@rails_book.id}?page=1&q=rails"
  end

  test "renders localized search controls" do
    I18n.with_locale(:ko) do
      get "/admin/product"
    end

    assert_select 'input[name="q"][placeholder="검색어 입력"]'
    assert_select 'select[name="filters[status]"] option[value=""]', text: "Status 전체"
  end

  private

  def reset_configuration
    JSAdmin.configure do |config|
      config.included_models = []
      config.records_per_page = 25
      config.field_settings = {}
      config.hide_filtered_columns = true
    end
  end
end
