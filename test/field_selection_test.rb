require "test_helper"

class FieldSelectionTest < ActiveSupport::TestCase
  setup do
    reset_field_configuration
  end

  teardown do
    reset_field_configuration
  end

  test "hides filtered columns from every screen by default" do
    resource = JSAdmin::Resource.new(User)

    assert_equal %w[id name], field_names(resource.list_fields)
    assert_equal %w[id created_at name updated_at], field_names(resource.show_fields)
    assert_equal %w[name], field_names(resource.form_fields)
  end

  test "selects default list columns after removing filtered columns" do
    original_filters = Rails.application.config.filter_parameters.dup
    Rails.application.config.filter_parameters << :category_id

    list_field_names = field_names(JSAdmin::Resource.new(Product).list_fields)

    assert_equal %w[id available description name price released_on status], list_field_names
  ensure
    Rails.application.config.filter_parameters.replace(original_filters)
  end

  test "selects default list columns after removing hidden columns" do
    JSAdmin.configure do |config|
      config.fields "Product", hidden: %i[category_id]
    end

    list_field_names = field_names(JSAdmin::Resource.new(Product).list_fields)

    assert_equal %w[id available description name price released_on status], list_field_names
  end

  test "uses configured columns in configured order including filtered columns" do
    JSAdmin.configure do |config|
      config.fields "User", list: %i[email name], show: %i[name email api_token], form: %i[email name]
    end
    resource = JSAdmin::Resource.new(User)

    assert_equal %w[email name], field_names(resource.list_fields)
    assert_equal %w[name email api_token], field_names(resource.show_fields)
    assert_equal %w[email name], field_names(resource.form_fields)
  end

  test "hidden columns take precedence over configured columns" do
    JSAdmin.configure do |config|
      config.fields User, list: %i[id name email], hidden: %i[email]
    end

    assert_equal %w[id name], field_names(JSAdmin::Resource.new(User).list_fields)
  end

  test "shows filtered columns when hide_filtered_columns is disabled" do
    JSAdmin.configure do |config|
      config.hide_filtered_columns = false
    end

    assert_equal %w[api_token email name password_digest], field_names(JSAdmin::Resource.new(User).form_fields)
  end

  test "merges field settings for the same model" do
    JSAdmin.configure do |config|
      config.fields "User", list: %i[id email]
      config.fields "User", hidden: %i[name]
    end

    assert_equal({ list: %w[id email], hidden: %w[name] }, JSAdmin.configuration.field_settings_for(User))
  end

  test "raises a configuration error for unknown columns" do
    JSAdmin.configure do |config|
      config.fields "User", hidden: %i[nickname]
    end

    error = assert_raises(JSAdmin::ConfigurationError) do
      JSAdmin::Resource.new(User).list_fields
    end

    assert_equal "User has no column named nickname.", error.message
  end

  test "raises a configuration error for non editable form columns" do
    JSAdmin.configure do |config|
      config.fields "User", form: %i[id name]
    end

    error = assert_raises(JSAdmin::ConfigurationError) do
      I18n.with_locale(:ko) { JSAdmin::Resource.new(User).form_fields }
    end

    assert_equal "User 모델의 id 컬럼은 수정할 수 없어 폼에 사용할 수 없습니다.", error.message
  end

  private

  def field_names(fields)
    fields.map(&:name)
  end

  def reset_field_configuration
    JSAdmin.configure do |config|
      config.field_settings = {}
      config.hide_filtered_columns = true
    end
  end
end
