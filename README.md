# QuickTodo

QuickTodo는 Obsidian/iCloud Drive 안의 Markdown 파일 하나를 그대로 source of truth로 사용하는 macOS 메뉴바 todo 패널 앱입니다.

## What It Does

- 단일 Markdown 파일 직접 열기/자동 저장
- 글로벌 토글 단축키 기본값 `⌘.`
- 항상 위에 뜨는 resizable panel
- 외부 변경 감지와 충돌 배너
- 메뉴바 유틸리티 + 로그인 시 자동 실행

## Build

현재 로컬 환경에서는 Swift Package 기반으로 바로 빌드할 수 있습니다.

```bash
swift build
swift run
```

## Package As `.app`

릴리스용 앱 번들은 아래 스크립트로 생성합니다.

```bash
chmod +x Scripts/build-app.sh Scripts/create-release-zip.sh Scripts/render-cask.sh
Scripts/build-app.sh release 0.1.0 1
Scripts/create-release-zip.sh 0.1.0 1
Scripts/render-cask.sh 0.1.0 "$(cat dist/QuickTodo.sha256)"
```

생성물:

- `dist/QuickTodo.app`
- `dist/QuickTodo.zip`
- `dist/QuickTodo.sha256`
- `Homebrew/quicktodo.rb`

## Homebrew Cask

예상 tap/repo 구조는 아래와 같습니다.

- 앱 저장소: `turastory/quicktodo`
- tap 저장소: `turastory/homebrew-tap`
- tap 식별자: `turastory/tap`
- cask token: `quicktodo`

릴리스 태그 `vX.Y.Z`가 올라가면 GitHub Actions가 zip, checksum, cask 파일을 생성합니다.

직접 공개할 때는 아래 스크립트를 순서대로 사용하면 됩니다.

```bash
chmod +x Scripts/publish-release.sh Scripts/publish-tap.sh Scripts/update-brewfile.sh
Scripts/publish-release.sh 0.1.0 1
Scripts/publish-tap.sh 0.1.0 "$(cat dist/QuickTodo.sha256)"
Scripts/update-brewfile.sh
```

## Dotfiles

tap 저장소가 실제로 공개된 뒤 `~/dotfiles/Brewfile`에 아래 두 줄을 추가하면 됩니다.

```ruby
tap "turastory/tap"
cask "quicktodo"
```

## Notes

- v1은 notarization 없이 동작하도록 설계했습니다.
- 첫 실행 시 Gatekeeper에서 허용이 필요할 수 있습니다.
