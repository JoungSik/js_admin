# 목록 컬럼 정렬 설계

- 이슈: #9
- 마일스톤: 0.3.0
- 선행 작업: #8 목록 검색과 필터 (`RecordQuery`)

## 결정 사항

| 항목 | 결정 |
|---|---|
| URL 파라미터 | `sort=<column>`, `direction=asc\|desc` |
| 정렬 가능 컬럼 | 목록 화면 컬럼(`Resource#list_fields`)만 허용. 그 외 컬럼, 잘못된 형식은 무시 |
| 방향 | `asc`/`desc` 외 값은 `asc` |
| 우선순위 | 요청 파라미터 > `default_sort` 설정 > primary key 내림차순 |
| 동순위 처리 | primary key 외 컬럼 정렬 시 primary key 내림차순 2차 정렬 |
| 헤더 UI | 컬럼명 링크. 현재 오름차순이면 내림차순, 그 외 오름차순으로 전환. 정렬 중인 컬럼은 화살표, `aria-sort`, 스크린 리더용 문구 표시 |
| 조건 유지 | 정렬 링크는 검색·필터 유지 + 1페이지 이동. 페이지네이션, 검색 폼, 초기화 링크, 삭제 요청은 정렬 유지 |

## 기본 정렬 설정

```ruby
config.default_sort "Post", :published_at, :desc
```

- direction 생략 시 `:asc`
- 잘못된 direction → `configure` 시점 `ConfigurationError`
- 모델에 없는 컬럼 → 해당 모델 목록 요청 시 `ConfigurationError`

## 구조

| 파일 | 역할 |
|---|---|
| `lib/js_admin/configuration.rb` | `default_sort`, `default_sort_for`, `default_sorts` |
| `lib/js_admin/record_query.rb` | 정렬 파라미터 정규화, `sort_params`, 정렬 scope 적용 |
| `lib/js_admin/resource.rb` | `records`는 페이지 분할만 담당. 기존 primary key 정렬은 `RecordQuery`로 이동 |
| `app/helpers/js_admin/application_helper.rb` | 헤더 정렬 링크·표시 helper |
