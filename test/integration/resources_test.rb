require "test_helper"

class ResourcesTest < ActionDispatch::IntegrationTest
  setup do
    JSAdmin.configure do |config|
      config.included_models = [ "Category", "Product" ]
      config.excluded_models = []
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
    end
  end

  test "lists configured active record models" do
    get "/js_admin"

    assert_response :success
    assert_select "a", text: /Product/
    assert_select "a", text: /Category/
  end

  test "renders column based form inputs" do
    get "/js_admin/product/new"

    assert_response :success
    assert_select 'input[name="product[name]"]'
    assert_select 'textarea[name="product[description]"]'
    assert_select 'input[type="number"][name="product[price]"]'
    assert_select 'input[type="checkbox"][name="product[available]"]'
    assert_select 'select[name="product[status]"]'
    assert_select 'select[name="product[category_id]"]'
  end

  test "creates a record through generic crud" do
    assert_difference "Product.count", 1 do
      post "/js_admin/product", params: {
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
    assert_redirected_to "/js_admin/product/#{created_product.id}"
    assert_equal "New Rails", created_product.name
    assert_equal "draft", created_product.status
  end

  test "updates a record through generic crud" do
    patch "/js_admin/product/#{@product.id}", params: {
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

    assert_redirected_to "/js_admin/product/#{@product.id}"
    assert_equal "Updated Rails", @product.reload.name
    assert_not @product.available
  end

  test "deletes a record through generic crud" do
    assert_difference "Product.count", -1 do
      delete "/js_admin/product/#{@product.id}"
    end

    assert_redirected_to "/js_admin/product"
  end
end
