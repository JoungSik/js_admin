# JSAdmin

JSAdmin is a mountable Rails engine that exposes Active Record models through a
generic CRUD UI. It discovers models from the host Rails application and builds
forms from database column metadata.

It is built for Rails 8.1+, Tailwind CSS, and Hotwire-compatible Rails helpers.

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

The install generator mounts JSAdmin at `/admin`, pins JSAdmin's JavaScript in
`config/importmap.rb`, and imports the engine Tailwind entrypoint when
`app/assets/tailwind/application.css` exists. You can choose another mount path:

```bash
bin/rails generate js_admin:install --path=/backoffice
bin/rails tailwindcss:engines
```

JSAdmin uses `importmap-rails` for JavaScript loading. Rails 8 default apps
already include `config/importmap.rb`; if it was removed, run
`bin/rails importmap:install` before running `js_admin:install`.

The generator adds these pins when they are missing:

```ruby
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "js_admin", to: "js_admin/application.js", preload: true
pin "js_admin/controllers/theme_controller", to: "js_admin/controllers/theme_controller.js", preload: true
pin "js_admin/controllers/flash_controller", to: "js_admin/controllers/flash_controller.js", preload: true
```

## Usage

Open the mounted path:

```text
/admin
```

The home page is intentionally empty. Model navigation lives in the sidebar.
By default, JSAdmin exposes every concrete Active Record model with an existing
database table. Namespaced models are grouped under namespace dropdowns. No
per-model field setup is required.

The UI includes a fixed header, fixed desktop sidebar, dark mode toggle, compact
pagination controls, and inline form validation errors. The default page size is
10 records.

The install generator also creates `config/initializers/js_admin.rb` with
commented configuration examples. JSAdmin works without changing that file.

Available configuration options:

| Option | Default | Description |
| --- | --- | --- |
| `included_models` | `[]` | Model names/classes to expose. Empty means every discovered concrete Active Record model. |
| `excluded_models` | `[]` | Model names/classes to hide after discovery. |
| `records_per_page` | `10` | Number of records shown per resource index page. |
| `association_limit` | `100` | Maximum number of associated records loaded into a `belongs_to` select. |
| `display_name_methods` | `%i[name title email username id]` | Methods tried in order when displaying records in tables and select labels. |
| `basic_auth_username` | `nil` | HTTP Basic Auth username. Auth is disabled unless username and password are both present. |
| `basic_auth_password` | `nil` | HTTP Basic Auth password. |
| `basic_auth_realm` | `"JSAdmin"` | HTTP Basic Auth realm. |
| `authenticate_with` | `nil` | Controller-context callback delegated to the host application's authentication. |
| `authorize_with` | `nil` | Optional controller-context callback that returns whether the authenticated user may access JSAdmin. |

Example:

```ruby
# config/initializers/js_admin.rb
JSAdmin.configure do |config|
  config.include_models User, Post
  config.exclude_models AuditLog
  config.records_per_page = 10
end
```

## Authentication

JSAdmin works without authentication unless Basic Auth credentials or an
authentication callback are configured. Choose exactly one of the following
authentication strategies.

For HTTP Basic Auth, configure both username and password:

```ruby
# config/initializers/js_admin.rb
JSAdmin.configure do |config|
  config.basic_auth_username = ENV["JS_ADMIN_BASIC_AUTH_USERNAME"]
  config.basic_auth_password = ENV["JS_ADMIN_BASIC_AUTH_PASSWORD"]
  config.basic_auth_realm = "JSAdmin"
end
```

To delegate authentication to the host application, provide a callback instead.
JSAdmin controllers inherit from the host application's `ApplicationController`,
and the callback runs in the controller context:

```ruby
# config/initializers/js_admin.rb
JSAdmin.configure do |config|
  config.authenticate_with do
    authenticate_user!
  end

  config.authorize_with do
    current_user&.admin?
  end
end
```

`authorize_with` is optional. When configured, returning `false` responds with
`403 Forbidden`. Basic Auth and `authenticate_with` cannot be configured
together. Partial Basic Auth credentials and `authorize_with` without
`authenticate_with` also raise `JSAdmin::ConfigurationError`.

For production apps, you can alternatively mount JSAdmin inside the host
application's admin authentication constraint.

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

## Hotwire Scope

JSAdmin depends on `importmap-rails`, `turbo-rails`, and `stimulus-rails` so it
works naturally in modern Rails apps using the Rails default Hotwire setup.

The admin shell keeps the header and sidebar stable while the main CRUD area is
wrapped in a Turbo Frame. Sidebar navigation, resource links, forms, and
pagination update that frame instead of replacing the whole page. Delete actions
can respond with Turbo Streams to refresh the flash region and resource list.

Stimulus controllers manage the dark mode toggle and auto-dismiss flash
messages. The selected theme is persisted in storage and a cookie so the engine
layout can render the initial dark class without inline JavaScript.

## Validation Errors

Form validation errors are rendered inside the form next to the matching field.
JSAdmin renders form controls directly so Rails' default `field_with_errors`
wrapper does not break the Tailwind grid layout. Errors that do not belong to an
editable field are shown at the top of the form.

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

### Dummy App

This repository includes `test/dummy` as the Rails engine test app. It is used by
the test suite and should stay small.

You can run it manually for functional checks:

```bash
bin/rails db:prepare
bin/rails server
```

Open:

```text
http://localhost:3000/admin
```

### Sandbox App

Use `sandbox/` when you want to verify the real installation flow in a fresh
Rails app. The sandbox directory is ignored by Git.

Create a sandbox app wired to this local checkout:

```bash
bin/setup_sandbox
```

The setup script creates several demo models, including a namespaced model, seeds
sample records, and runs an initial Tailwind build.

Run a one-off browser check:

```bash
cd sandbox
bin/rails server
```

For iterative UI/CSS development, run the Rails server and Tailwind watcher
together:

```bash
cd sandbox
bin/dev
```

Open:

```text
http://localhost:3000/admin
```

Rebuild it from scratch:

```bash
rm -rf sandbox
bin/setup_sandbox
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
