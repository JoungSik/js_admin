# Release Notes

이 문서는 version, changelog, GitHub Actions, RubyGems 배포, tag 처리가 필요할 때만 읽습니다.

## 배포 방식

JSAdmin은 RubyGems Trusted Publishing을 사용합니다.

- RubyGems gem: `js_admin`
- Release workflow: `.github/workflows/release.yml`
- tag pattern: `v*`
- GitHub environment: `release`
- Repository: `JoungSik/js_admin`

## 새 버전 배포 절차

1. `lib/js_admin/version.rb` 버전 변경
2. `CHANGELOG.md` 갱신
3. `bundle exec rails test`
4. `gem build js_admin.gemspec`
5. commit 및 `main` push
6. matching tag push

예:

```bash
git tag v0.0.2
git push origin v0.0.2
```

한 번 RubyGems에 올라간 같은 version은 덮어쓸 수 없습니다. 수정 배포가 필요하면 version을 올립니다.

## Tag 처리

`git push --force`와 `git push --force-with-lease`는 사용하지 않습니다.

실패한 release tag를 같은 version으로 다시 걸어야 할 때는 force push 대신 원격 tag 삭제 후 새 tag push를 사용합니다.

```bash
git tag -d v0.0.2
git push origin :refs/tags/v0.0.2
git tag v0.0.2
git push origin v0.0.2
```

단, 해당 version이 RubyGems에 이미 성공적으로 올라갔다면 같은 version을 다시 배포하지 말고 version을 올립니다.
