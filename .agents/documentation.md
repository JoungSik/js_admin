# Documentation Notes

이 문서는 README, CHANGELOG, AGENTS, CLAUDE 등 문서 작업이 필요할 때만 읽습니다.

## 문서 역할

- `README.md`: 사용자-facing 설치, 사용법, 인증 주의, 개발/릴리스 안내
- `CHANGELOG.md`: release 변경사항
- `AGENTS.md`: LLM agent entrypoint와 항상 적용할 최소 규칙
- `CLAUDE.md`: Claude가 `AGENTS.md`를 참조하도록 안내하는 얇은 파일
- `.agents/*.md`: 작업 유형별 상세 지침

## 작성 기준

- 설명과 요약은 한국어로 작성합니다.
- 코드, command, file path, class/module/gem/API 이름은 원문을 유지합니다.
- `CLAUDE.md`에 상세 지침을 중복 작성하지 않습니다. 상세 지침은 `AGENTS.md` 또는 `.agents/*.md`에 둡니다.
- `AGENTS.md`는 매번 로딩되는 파일이므로 짧게 유지합니다.
- 상세 지침은 필요할 때만 읽을 수 있도록 `.agents/*.md`로 분리합니다.

## README 기준

README는 공개 gem 사용자 기준으로 작성합니다.

- 설치 예시는 `gem "js_admin"`을 사용합니다.
- 로컬 개발용 `path: "../js_admin"` 예시는 기본 설치 섹션에 넣지 않습니다.
- Basic Auth는 username/password가 모두 설정된 경우에만 켜진다고 명시합니다.
- production 사용 시 Basic Auth 또는 host app의 authentication constraint를 사용하라고 명시합니다.
