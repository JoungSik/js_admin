# Architecture Notes

JSAdmin은 Rails mountable engine gem입니다. host app 모델을 직접 생성하지 않고, host app의 Active Record metadata를 읽어 generic CRUD UI를 제공합니다.

## Core Invariants

- Gem name: `js_admin`
- Ruby namespace: `JSAdmin`
- 기본 mount path: `/admin`
- Runtime dependencies: `rails`, `tailwindcss-rails`, `turbo-rails`, `stimulus-rails`
- optional Basic Auth는 `JSAdmin.configuration`에서 제공합니다. 더 강한 인증/인가가 필요하면 host app의 admin authentication constraint 뒤에 mount합니다.
- 기본 pagination size는 10 records입니다.

## 주요 구조

- `lib/js_admin.rb`: gem entrypoint
- `lib/js_admin/engine.rb`: Rails engine, `JS` acronym inflection, namespace isolation
- `lib/js_admin/registry.rb`: host app의 관리 가능 모델 탐색
- `lib/js_admin/resource.rb`: 모델 단위 CRUD resource abstraction
- `lib/js_admin/field.rb`: column metadata 기반 input mapping
- `app/controllers/js_admin`: generic CRUD controllers
- `app/views/js_admin`: Tailwind 기반 admin views
- `app/views/js_admin/home/index.html.erb`: 아직 dashboard 데이터가 정해지지 않은 빈 home
- `app/views/layouts/js_admin/_sidebar.html.erb`: top-level model과 namespaced model dropdown navigation
- `app/assets/tailwind/js_admin/engine.css`: engine Tailwind entrypoint
- `lib/generators/js_admin/install/install_generator.rb`: route mount 및 Tailwind import generator
- `JSAdmin::Configuration#basic_auth_enabled?`: username/password 설정 시 Basic Auth 활성화

## Naming

파일, 경로, gem name, generator name은 `js_admin`을 사용합니다.

Ruby 상수는 `JSAdmin`을 사용합니다. `lib/js_admin/engine.rb`의 inflection 설정이 깨지면 Zeitwerk autoload가 실패할 수 있습니다.

## CRUD 설계

- 모델 발견은 `JSAdmin::Registry`에서 처리합니다.
- 모델별 표현은 `JSAdmin::Resource`가 담당합니다.
- column input mapping은 `JSAdmin::Field`가 담당합니다.
- controller는 모델별 controller를 만들지 않고 `JSAdmin::ResourcesController` 하나로 generic CRUD를 처리합니다.
- `/admin` root는 비어 있는 home입니다. 모델 탐색은 layout sidebar에서 처리합니다.
- 데스크톱 sidebar는 content와 독립적으로 고정되어야 하며, theme toggle은 sidebar 하단에 둡니다.
- form validation error는 field 아래 inline으로 표시합니다. Rails 기본 `field_with_errors` wrapper에 CSS로 대응하지 말고, JSAdmin form helper에서 input/label/error markup을 직접 관리합니다.
- 현재 Hotwire 사용은 Turbo Drive 호환 Rails links/forms와 `data-turbo-confirm` 중심입니다. Turbo Frames/Streams 또는 Stimulus controller 기반 부분 업데이트는 아직 구현되어 있지 않으며, 추가할 때는 content frame, form validation, flash/table 갱신 단위로 점진 적용합니다.

## Field Mapping

- `text`: textarea
- `boolean`: checkbox
- `integer`, `bigint`, `float`, `decimal`: number input
- `date`, `datetime`, `time`: matching date/time input
- Rails enum: select
- `belongs_to` foreign key: select
- 그 외: text input

Primary key, timestamps, STI inheritance column, readonly attribute, generated column은 editable field에서 제외합니다.
