require "test_helper"

class ResourceSortTest < ActionDispatch::IntegrationTest
  setup do
    reset_configuration
    JSAdmin.configure do |config|
      config.included_models = [ "Category", "Product", "User" ]
    end

    @category = Category.create!(name: "Books")
    @banana = Product.create!(category: @category, name: "Banana", price: 3, available: true, status: :draft)
    @apple = Product.create!(category: @category, name: "Apple", price: 5, available: false, status: :published)
    @cherry = Product.create!(category: @category, name: "Cherry", price: 1, available: true, status: :draft)
  end

  teardown do
    Product.delete_all
    Category.delete_all
    reset_configuration
  end

  test "orders by primary key descending by default" do
    get "/admin/product"

    assert_equal %w[Cherry Apple Banana], rendered_product_names
  end

  test "sorts by a list column in ascending order" do
    get "/admin/product", params: { sort: "name", direction: "asc" }

    assert_equal %w[Apple Banana Cherry], rendered_product_names
  end

  test "sorts by a list column in descending order" do
    get "/admin/product", params: { sort: "price", direction: "desc" }

    assert_equal %w[Apple Banana Cherry], rendered_product_names
  end

  test "uses ascending order for invalid directions" do
    get "/admin/product", params: { sort: "name", direction: "sideways" }

    assert_equal %w[Apple Banana Cherry], rendered_product_names
  end

  test "ignores columns outside the list and malformed sort parameters" do
    get "/admin/product", params: { sort: "status", direction: "asc" }
    assert_equal %w[Cherry Apple Banana], rendered_product_names

    get "/admin/product", params: { sort: "name; DROP TABLE products", direction: "asc" }
    assert_equal %w[Cherry Apple Banana], rendered_product_names

    get "/admin/product", params: { sort: [ "name" ], direction: { value: "asc" } }
    assert_response :success
    assert_equal %w[Cherry Apple Banana], rendered_product_names
  end

  test "breaks ties by primary key descending" do
    Product.where(id: [ @banana.id, @cherry.id ]).update_all(price: 3)

    get "/admin/product", params: { sort: "price", direction: "asc" }

    assert_equal %w[Cherry Banana Apple], rendered_product_names
  end

  test "renders sort links that toggle direction for the sorted column" do
    get "/admin/product", params: { sort: "name", direction: "asc", q: "a" }

    assert_select 'th[aria-sort="ascending"] a[href=?]', "/admin/product?direction=desc&page=1&q=a&sort=name"
    assert_select "th a[href=?]", "/admin/product?direction=asc&page=1&q=a&sort=price"
    assert_select 'th[aria-sort="ascending"] .sr-only', text: "sorted ascending"
  end

  test "keeps sort in pagination links search form and clear link" do
    JSAdmin.configure do |config|
      config.records_per_page = 1
    end

    get "/admin/product", params: { sort: "name", direction: "desc", q: "e" }

    assert_select "nav a[href=?]", "/admin/product?direction=desc&page=2&q=e&sort=name"
    assert_select 'form[method="get"] input[type="hidden"][name="sort"][value="name"]'
    assert_select 'form[method="get"] input[type="hidden"][name="direction"][value="desc"]'
    assert_select "a[href=?]", "/admin/product?direction=desc&sort=name", text: "Clear"
  end

  test "keeps sort after deleting through turbo stream" do
    delete "/admin/product/#{@cherry.id}", params: { sort: "name", direction: "asc" }, headers: {
      "Accept" => "text/vnd.turbo-stream.html"
    }

    assert_equal %w[Apple Banana], rendered_product_names
  end

  test "uses configured default sort" do
    JSAdmin.configure do |config|
      config.default_sort "Product", :name
    end

    get "/admin/product"

    assert_equal %w[Apple Banana Cherry], rendered_product_names
    assert_select 'th[aria-sort="ascending"]', 1
  end

  test "requested sort overrides configured default sort" do
    JSAdmin.configure do |config|
      config.default_sort "Product", :name, :asc
    end

    get "/admin/product", params: { sort: "price", direction: "asc" }

    assert_equal %w[Cherry Banana Apple], rendered_product_names
  end

  test "renders localized sort state" do
    I18n.with_locale(:ko) do
      get "/admin/product", params: { sort: "name", direction: "desc" }
    end

    assert_select 'th[aria-sort="descending"] .sr-only', text: "내림차순 정렬됨"
  end

  private

  def rendered_product_names
    css_select("tbody tr").filter_map do |row|
      [ "Apple", "Banana", "Cherry" ].find { |name| row.text.include?(name) }
    end
  end

  def reset_configuration
    JSAdmin.configure do |config|
      config.included_models = []
      config.records_per_page = 25
      config.field_settings = {}
      config.default_sorts = {}
      config.hide_filtered_columns = true
    end
  end
end
