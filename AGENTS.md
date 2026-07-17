# AGENTS.md

이 파일은 이 repository에서 작업하는 LLM agent의 entrypoint입니다. 항상 필요한 최소 규칙만 여기에 두고, 상세 내용은 작업 유형에 따라 `.agents/*.md`에서 필요한 것만 읽습니다.

## 항상 적용

- 설명, 요약, 사용자-facing 답변은 한국어로 작성합니다.
- 코드, command, file path, class/module/gem/API 이름은 원문을 유지합니다.
- 작고 집중된 변경을 선호하고, 불필요한 리팩터링이나 formatting churn을 피합니다.
- Gem name은 `js_admin`, Ruby namespace는 `JSAdmin`입니다. 명시 요청 없이 이름을 바꾸지 않습니다.
- `JSAdmin` 상수를 유지하기 위해 `JS` acronym 설정을 신중히 다룹니다.
- 사용자가 명시적으로 요청하지 않으면 commit 또는 push하지 않습니다.
- `git push --force`와 `git push --force-with-lease`는 사용하지 않습니다.
- commit message는 `git commit -m "<type>: <Korean summary>"` 형식의 한 줄로 작성합니다.
- `Co-Authored-By` trailer를 추가하지 않습니다.

## 필요한 지침 로딩

작업을 시작할 때 아래 기준에 맞는 문서만 추가로 읽습니다. 관련 없는 상세 문서는 로딩하지 않습니다.

- 코드 구조, 기능 추가, 버그 수정, Rails engine 동작 변경: `.agents/architecture.md`
- 테스트, dummy app, sandbox, 로컬 실행, 생성 산출물 처리: `.agents/development.md`
- version, changelog, GitHub Actions, RubyGems 배포, tag 처리: `.agents/release.md`
- README, CHANGELOG, AGENTS, CLAUDE 등 문서 작업: `.agents/documentation.md`

## 프로젝트 한 줄 요약

JSAdmin은 Rails 8.1+용 mountable engine gem입니다. host Rails app의 Active Record 모델을 발견하고 database column metadata를 기반으로 CRUD
UI와 form input을 자동 구성합니다.

## 빠른 검증

일반 코드 변경 후 기본 검증은 다음을 우선 고려합니다.

```bash
bundle exec rails test
```

gem packaging 또는 release 관련 변경이 있으면 추가로 실행합니다.

```bash
gem build js_admin.gemspec
bundle check
```
