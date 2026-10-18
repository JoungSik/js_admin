# 목록 검색과 필터 설계

- 이슈: #8
- 마일스톤: 0.3.0
- 선행 작업: #7 필드 노출 설정

## 결정 사항

| 항목 | 결정 |
|---|---|
| 검색 대상 기본값 | 상세 화면 기본 규칙에서 노출되는 `string`/`text` 컬럼. 숨김·필터 대상 컬럼은 검색하지 않음 |
| 검색 대상 설정 | `config.fields "User", search: %i[name email]`. 명시하면 필터 대상 컬럼도 검색 가능, `hidden` 우선 |
| 검색 방식 | 대상 컬럼 OR 조건 부분 일치. Arel `matches`(PostgreSQL은 ILIKE) + `sanitize_sql_like`로 `%`, `_` 이스케이프 |
| 필터 대상 | 상세 화면 컬럼 중 `belongs_to`(polymorphic 제외), enum, boolean. 목록 기본 컬럼 6개에 들지 않는 enum도 필터 가능하도록 상세 화면 기준 사용 |
| 필터 값 검증 | boolean은 `true`/`false`, enum은 정의된 key, association은 비어 있지 않은 값만 허용. 그 외 값과 대상이 아닌 컬럼은 무시 |
| URL 파라미터 | `q`, `filters[<column>]` |
| 조건 유지 | 페이지네이션 링크, Turbo Stream 삭제 후 목록 갱신에서 `q`, `filters`, `page` 유지 |
| 잘못된 설정 | `search:`에 문자열·텍스트가 아닌 컬럼 → `ConfigurationError` |

## 구조

| 파일 | 역할 |
|---|---|
| `lib/js_admin/record_query.rb` | 검색어·필터 정규화와 scope 생성 Service Object. #9 정렬도 이곳에 추가 |
| `lib/js_admin/field.rb` | `searchable?`, `filter_kind`, `filterable?`, `filter_options` |
| `lib/js_admin/field_selection.rb` | `:search` 화면 규칙 |
| `lib/js_admin/resource.rb` | `search_fields`, `filter_fields`, `records(page:, scope:)` |
| `app/views/js_admin/resources/_search_form.html.erb` | GET 폼. Turbo Frame 안에서 목록만 갱신 |

## 범위 제외

- 필터 대상 컬럼 설정 (상세 화면 컬럼 설정으로 간접 조정)
- 날짜·숫자 범위 필터
