# Architecture Notes

JSAdmin은 Rails mountable engine gem입니다. host app 모델을 직접 생성하지 않고, host app의 Active Record metadata를 읽어 generic CRUD UI를 제공합니다.

## Core Invariants

- Gem name: `js_admin`
- Ruby namespace: `JSAdmin`
- 기본 mount path: `/admin`
- Runtime dependencies: `rails`, `importmap-rails`, `tailwindcss-rails`, `turbo-rails`, `stimulus-rails`
- 인증은 미설정, Basic Auth, host application callback 중 하나를 사용합니다. Basic Auth와 callback을 동시에 설정하지 않습니다.
- 기본 pagination size는 10 records입니다.
- JSAdmin 소유의 사용자-facing 문자열은 `js_admin.*` I18n namespace에서 관리하고 `en`/`ko` locale을 기본 제공합니다.

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
- `lib/generators/js_admin/install/install_generator.rb`: route mount, importmap pin, Tailwind import generator
- `JSAdmin::Configuration#basic_auth_enabled?`: username/password 설정 시 Basic Auth 활성화
- `JSAdmin::Configuration#authenticate_with`: host application 인증 callback 등록
- `JSAdmin::Configuration#authorize_with`: 인증된 사용자의 JSAdmin 접근 권한 callback 등록

## Naming

파일, 경로, gem name, generator name은 `js_admin`을 사용합니다.

Ruby 상수는 `JSAdmin`을 사용합니다. `lib/js_admin/engine.rb`의 inflection 설정이 깨지면 Zeitwerk autoload가 실패할 수 있습니다.

## I18n

- JSAdmin이 직접 표시하는 UI title, navigation, button, table, pagination, confirmation, accessibility label, flash, 설정 오류, generator 메시지는 문자열을 hardcode하지 않고 `js_admin.*` key를 사용합니다.
- 새 key를 추가하거나 기존 문구를 변경할 때 `config/locales/js_admin.en.yml`과 `config/locales/js_admin.ko.yml`을 함께 갱신하고 두 locale의 key 구조를 일치시킵니다.
- 동적 모델명, record명, count는 문자열 결합 대신 interpolation을 사용합니다. 수량 문구는 `count`를 전달해 pluralization을 적용하고, 표시 형식이 필요하면 `formatted_count`처럼 별도 값을 전달합니다.
- 모델명과 attribute명은 host app의 번역을 존중하도록 `model_name.human`과 `human_attribute_name`을 사용합니다.
- Active Model validation message는 host app과 Rails I18n이 소유하므로 JSAdmin locale에 중복 정의하지 않고 record의 `errors`를 표시합니다.
- `JSAdmin`, class/module/API 이름, file path, HTML attribute 값처럼 번역 대상이 아닌 기술 식별자는 원문을 유지합니다.
- I18n 변경에는 기본 locale 동작과 지원 locale 중 하나 이상의 렌더링 또는 오류 메시지 테스트를 포함합니다.

## CRUD 설계

- 모델 발견은 `JSAdmin::Registry`에서 처리합니다.
- 모델별 표현은 `JSAdmin::Resource`가 담당합니다.
- column input mapping은 `JSAdmin::Field`가 담당합니다.
- controller는 모델별 controller를 만들지 않고 `JSAdmin::ResourcesController` 하나로 generic CRUD를 처리합니다.
- `/admin` root는 비어 있는 home입니다. 모델 탐색은 layout sidebar에서 처리합니다.
- 데스크톱 sidebar는 content와 독립적으로 고정되어야 하며, theme toggle은 sidebar 하단에 둡니다.
- form validation error는 field 아래 inline으로 표시합니다. Rails 기본 `field_with_errors` wrapper에 CSS로 대응하지 말고, JSAdmin form helper에서 input/label/error markup을 직접 관리합니다.
- main CRUD 영역은 `js_admin_content` Turbo Frame으로 감싸고, header/sidebar는 frame 밖에 고정합니다.
- sidebar/header navigation은 `js_admin_content`를 target으로 지정해 shell 전체 교체를 피합니다.
- Turbo Stream 응답은 flash region과 `js_admin_content_body`처럼 필요한 대상만 갱신합니다.
- dark mode toggle과 flash auto-dismiss는 `js-admin-theme`, `js-admin-flash` Stimulus controller에서 관리합니다. 저장된 theme는 cookie로도 유지해 layout이 inline script 없이 초기 dark class를 렌더링합니다.
- JSAdmin JavaScript는 `config/importmap.rb`의 `js_admin` entrypoint pin과 `js_admin/controllers/*` controller pin을 통해 로딩합니다. engine layout에서는 `javascript_importmap_tags "js_admin"`를 사용합니다.

## Field Mapping

- `text`: textarea
- `boolean`: checkbox
- `integer`, `bigint`, `float`, `decimal`: number input
- `date`, `datetime`, `time`: matching date/time input
- `select_options` 설정 column: select (callable은 form 렌더링마다 평가)
- Rails enum: select
- `belongs_to` foreign key: select
- 그 외: text input

Primary key, timestamps, STI inheritance column, readonly attribute, generated column은 editable field에서 제외합니다.
