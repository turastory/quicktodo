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
chmod +x Scripts/release-common.sh Scripts/build-app.sh Scripts/create-release-zip.sh
Scripts/build-app.sh release 0.1.0 1
Scripts/create-release-zip.sh 0.1.0 1
```

생성물:

- `dist/QuickTodo.app`
- `dist/QuickTodo.zip`
- `dist/QuickTodo.sha256`

## Homebrew Cask

예상 tap/repo 구조는 아래와 같습니다.

- 앱 저장소: `turastory/quicktodo`
- tap 저장소: `turastory/homebrew-tap`
- tap 식별자: `turastory/tap`
- cask token: `quicktodo`

릴리스 태그 `vX.Y.Z`가 올라가면 app 저장소의 GitHub Actions가 zip과 checksum을 생성하고 GitHub Release를 만든 뒤, tap 저장소로 `repository_dispatch`를 보내 cask 생성/검증/커밋을 위임합니다.

자동화 전제:

- 앱 저장소 GitHub Actions secret: `HOMEBREW_TAP_GITHUB_TOKEN`
- 권한: `turastory/homebrew-tap` 저장소에 dispatch 요청을 보낼 수 있는 classic PAT 또는 fine-grained token
- cask source of truth: `turastory/homebrew-tap`

직접 공개할 때는 아래 스크립트를 순서대로 사용하면 됩니다.

```bash
chmod +x Scripts/release-common.sh Scripts/publish-release.sh Scripts/dispatch-tap-update.sh
Scripts/publish-release.sh 0.1.0 1
```

릴리스는 이미 만들어졌고 tap 갱신만 다시 보내고 싶다면 아래 스크립트를 따로 실행하면 됩니다.

```bash
Scripts/dispatch-tap-update.sh 0.1.0 "$(cat dist/QuickTodo.sha256)" v0.1.0
```

스크립트들은 기본값으로 `turastory/quicktodo`, `turastory/homebrew-tap`, `quicktodo`, `ventura`를 사용하고, 필요하면 아래 환경 변수로 바꿀 수 있습니다.

```bash
export QUICKTODO_APP_REPO="owner/quicktodo"
export QUICKTODO_TAP_REPO="owner/homebrew-tap"
export QUICKTODO_TAP_NAME="owner/tap"
export QUICKTODO_CASK_TOKEN="quicktodo"
export QUICKTODO_MIN_MACOS="ventura"
```

## Brewfile

tap 저장소가 공개된 뒤 로컬 `Brewfile`에는 아래 두 줄만 추가하면 됩니다.

```ruby
tap "turastory/tap"
cask "quicktodo"
```

## Notes

- v1은 notarization 없이 동작하도록 설계했습니다.
- 첫 실행 시 Gatekeeper에서 허용이 필요할 수 있습니다.
