# 필드 노출 설정과 민감 컬럼 기본 숨김 설계

- 이슈: #7
- 마일스톤: 0.3.0

## 배경

- 목록 컬럼이 primary key + 앞쪽 6개 컬럼으로 고정되어 모델별 조정 불가
- `password_digest`, `*_token` 등 민감 컬럼이 목록·상세·폼에 노출되고 수정 가능

## 설정 API

```ruby
JSAdmin.configure do |config|
  config.hide_filtered_columns = true # 기본값

  config.fields "User",
    list: %i[id name email],
    show: %i[id name email created_at],
    form: %i[name email],
    hidden: %i[api_token]
end
```

- `select_options`와 같은 모델명 + 키워드 패턴
- 모든 키워드 생략 가능. 같은 모델에 여러 번 호출하면 키 단위 병합
- `field_settings` 해시에 저장

## 민감 컬럼 판정

- host 앱의 `Rails.application.config.filter_parameters`를 `ActiveSupport::ParameterFilter`로 적용
- Rails 기본값에 `:email`이 포함되어 email 컬럼도 기본 숨김 대상

## 화면별 컬럼 선택 규칙

| 단계 | 명시한 화면 | 명시하지 않은 화면 |
|---|---|---|
| 1. 후보 | `list/show/form`에 지정한 컬럼, 지정 순서 유지 | 기본 규칙 (목록: id + 앞쪽 6개 / 상세: 전체 / 폼: `editable_fields`) |
| 2. `filter_parameters` | 적용 안 함 | `hide_filtered_columns`가 켜져 있으면 일치 컬럼 제외 |
| 3. `hidden` | 제외 | 제외 |

- 우선순위: `hidden` > 명시 설정 > `filter_parameters` > 기본 규칙
- 목록 기본 규칙은 숨김 컬럼을 제외한 뒤 6개 선택
- strong parameters는 폼 화면의 최종 컬럼만 허용

## 잘못된 설정

- 모델에 없는 컬럼명, `form:`의 수정 불가 컬럼 → `JSAdmin::ConfigurationError` (en/ko 메시지)
- 검증은 해당 모델 화면 요청 시점에 수행. initializer 실행 시점에는 모델·컬럼 정보가 로드되지 않았을 수 있음

## 구조

| 파일 | 역할 |
|---|---|
| `lib/js_admin/configuration.rb` | `hide_filtered_columns`, `field_settings`, `fields`, `field_settings_for` |
| `lib/js_admin/field.rb` | `filtered?` |
| `lib/js_admin/field_selection.rb` | 화면별 컬럼 선택 Service Object |
| `lib/js_admin/resource.rb` | `list_fields`, `show_fields`, `form_fields` 위임 |
| 뷰·컨트롤러·헬퍼 | 상세는 `show_fields`, 폼·strong parameters·폼 오류는 `form_fields` 사용 |

## 테스트

- dummy app에 `User`(`name`, `email`, `password_digest`, `api_token`) 추가
- `FieldSelection` 단위 테스트: 기본 숨김, 6개 선택, 명시 순서, `hidden` 우선, 토글, 병합, 설정 오류
- 통합 테스트: 민감 컬럼 미렌더링, strong parameters 차단, 명시한 email 노출
