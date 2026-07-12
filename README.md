# JSAdmin

JSAdmin is a mountable Rails engine that exposes Active Record models through
a generic CRUD UI. It discovers models from the host Rails application and builds
forms from database column metadata.

> 2026-07-12 기준 RubyGems API에서 `js_admin`은 등록되지 않은 이름으로 확인했습니다. 공개 배포 직전에는 다시 한 번 점유 여부를 확인하세요.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "js_admin", path: "../js_admin"
```

And then execute:

```bash
bundle install
bin/rails generate js_admin:install
bin/rails tailwindcss:engines
```

The install generator mounts the engine at `/js_admin` and imports the engine
Tailwind entrypoint when `app/assets/tailwind/application.css` exists.

## Usage

Open:

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

## Security

Zero model configuration is convenient, but it is dangerous to expose without
authentication. In production, mount the engine inside your app's admin
authentication constraint.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
