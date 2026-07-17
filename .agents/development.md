# Development Notes

이 문서는 테스트, dummy app, sandbox, 로컬 실행, 생성 산출물 처리가 필요할 때만 읽습니다.

## 기본 검증

```bash
bundle exec rails test
bundle check
```

패키징 관련 변경이면 다음도 확인합니다.

```bash
gem build js_admin.gemspec
```

검증으로 생성된 `.gem`, sqlite DB, log, `local_secret.txt`는 commit하지 않습니다.

## Dummy App

`test/dummy`는 Rails engine 테스트에 필요한 app이므로 repository에 포함합니다. 단, 실행 중 생성되는 산출물은 commit하지 않습니다.

ignore 대상 예:

- `test/dummy/log/*.log`
- `test/dummy/storage/*.sqlite3`
- `test/dummy/tmp/local_secret.txt`
- `*.gem`

`test/dummy`는 CI와 integration test용입니다. 사람이 브라우저로 실제 설치 흐름을 확인하는 용도는 `sandbox/`를 사용합니다.

## Dummy App 임시 동작 확인

repo 내부 dummy app으로 기능 동작을 확인할 수 있습니다. Tailwind watcher까지 포함한 브라우저 확인은 `sandbox/`를 사용합니다.

```bash
bin/rails db:prepare
bin/rails runner 'category = Category.create!(name: "Books"); Product.create!(category: category, name: "Rails Book", description: "Test product", price: 19.9, available: true, status: 0, released_on: Date.current)'
bin/rails server
```

확인 URL:

```text
http://localhost:3000/admin
```

## Sandbox App

`sandbox/`는 실제 Rails 앱에 JSAdmin을 설치하는 흐름을 검증하기 위한 ignored app입니다. repository에 commit하지 않습니다.

자동 생성:

```bash
bin/setup_sandbox
```

생성되는 sandbox는 로컬 checkout을 사용하고, UI 확인을 위한 demo model과 seed data를 포함합니다.

```ruby
gem "js_admin", path: ".."
```

실행:

```bash
cd sandbox
bin/rails server
```

`bin/setup_sandbox`는 초기 Tailwind build를 실행하므로 단발 브라우저 확인은 `bin/rails server`로 충분합니다.

UI/CSS를 수정하면서 확인할 때는 Rails server와 Tailwind watcher를 함께 실행합니다.

```bash
cd sandbox
bin/dev
```

확인 URL:

```text
http://localhost:3000/admin
```

처음부터 다시 만들고 싶으면 `sandbox/`를 삭제한 뒤 재실행합니다.

```bash
rm -rf sandbox
bin/setup_sandbox
```

## GitHub Actions와 Lockfile

GitHub Actions는 Linux runner에서 실행되므로 `Gemfile.lock`에는 `x86_64-linux` platform이 포함되어 있어야 합니다.

필요하면 다음 명령을 사용합니다.

```bash
bundle lock --add-platform x86_64-linux
```
