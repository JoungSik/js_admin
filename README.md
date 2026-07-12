# JSAdmin

JSAdmin is a mountable Rails engine that exposes Active Record models through a
generic CRUD UI. It discovers models from the host Rails application and builds
forms from database column metadata.

It is built for Rails 8.1+, Tailwind CSS, Turbo, and Stimulus.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "js_admin"
```

Install and mount the engine:

```bash
bundle install
bin/rails generate js_admin:install
bin/rails tailwindcss:engines
```

The install generator mounts JSAdmin at `/js_admin` and imports the engine
Tailwind entrypoint when `app/assets/tailwind/application.css` exists. You can
choose another mount path:

```bash
bin/rails generate js_admin:install --path=/admin
bin/rails tailwindcss:engines
```

## Usage

Open the mounted path:

```text
/js_admin
```

By default, JSAdmin lists every concrete Active Record model with an existing
database table. No per-model field setup is required.

Optional model filtering:

```ruby
# config/initializers/js_admin.rb
JSAdmin.configure do |config|
  config.include_models User, Post
  config.exclude_models AuditLog
  config.records_per_page = 50
end
```

## Authentication

JSAdmin does not provide authentication. In production, mount the engine inside
your application's admin authentication constraint.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  authenticate :user, ->(user) { user.admin? } do
    mount JSAdmin::Engine => "/admin"
  end
end
```

## Field Mapping

JSAdmin maps database columns to inputs automatically:

| Column metadata | Input |
| --- | --- |
| `text` | `textarea` |
| `boolean` | checkbox |
| `integer`, `bigint`, `float`, `decimal` | number input |
| `date`, `datetime`, `time` | matching date/time input |
| Rails enum | select |
| `belongs_to` foreign key | select |
| other columns | text input |

Primary keys, timestamps, STI inheritance columns, readonly attributes, and
generated columns are not editable.

## Development

Run the test suite:

```bash
bundle install
bundle exec rails test
```

Build the gem locally:

```bash
gem build js_admin.gemspec
```

## Release

Releases are published to RubyGems through GitHub Actions and RubyGems Trusted
Publishing. To release a new version, update `lib/js_admin/version.rb`, update
`CHANGELOG.md`, and push a matching tag:

```bash
git tag v0.0.2
git push origin v0.0.2
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
