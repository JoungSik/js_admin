require "test_helper"

class RecordQueryTest < ActiveSupport::TestCase
  teardown do
    JSAdmin.configure do |config|
      config.default_sorts = {}
    end
  end

  test "stores default sort with ascending direction by default" do
    JSAdmin.configure do |config|
      config.default_sort Product, :name
    end

    assert_equal [ "name", "asc" ], JSAdmin.configuration.default_sort_for("Product")
  end

  test "rejects invalid default sort directions when configuring" do
    error = assert_raises(JSAdmin::ConfigurationError) do
      JSAdmin.configure do |config|
        config.default_sort "Product", :name, :sideways
      end
    end

    assert_equal "Sort direction must be asc or desc: sideways", error.message
  end

  test "raises a configuration error for unknown default sort columns" do
    JSAdmin.configure do |config|
      config.default_sort "Product", :rating, :desc
    end

    error = assert_raises(JSAdmin::ConfigurationError) do
      JSAdmin::RecordQuery.new(JSAdmin::Resource.new(Product)).scope
    end

    assert_equal "Product has no column named rating.", error.message
  end

  test "builds sort params only for requested sort" do
    resource = JSAdmin::Resource.new(Product)

    assert_equal({}, JSAdmin::RecordQuery.new(resource).sort_params)
    assert_equal(
      { sort: "name", direction: "asc" },
      JSAdmin::RecordQuery.new(resource, sort_column: "name", sort_direction: "up").sort_params
    )
  end
end
