# ai-config

Claude Code(`~/.claude`)와 Codex(`~/.codex`)의 개인 전역 설정을 한 저장소에서 관리한다.

여러 기기(Mac / Windows)에서 두 도구를 **같은 지침·같은 설정**으로 쓰는 것이 목적이다.
설정 원본은 이 저장소에만 두고, 실제 경로에는 심볼릭 링크를 걸어 각 도구가 원래 자리에서 읽게 한다.

## 구조

```
~/ai-config/
  claude/
    CLAUDE.md              # ★ 공통 개발 지침 본문 (Claude Code와 Codex가 함께 보는 단일 원본)
    settings.json          # model, permissions, statusLine, hooks 등
    statusline-command.sh  # 상태줄 스크립트
    rules/                 # 항상 로드되는 추가 규칙
    skills/                # 전역 스킬
    commands/              # 전역 슬래시 커맨드
    plugins.conf           # 자동 설치할 마켓플레이스·플러그인 목록
    mcp.example.json       # 사용자 범위 MCP 설정 예시 (키 제외, 링크하지 않음)
  install.sh               # 심볼릭 링크 생성
```

링크는 아래와 같이 걸린다.

| 실제 경로 (도구가 읽는 위치) | 저장소 원본 |
|---|---|
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` |
| `~/.claude/settings.json` | `claude/settings.json` |
| `~/.claude/statusline-command.sh` | `claude/statusline-command.sh` |
| `~/.claude/rules` | `claude/rules` |
| `~/.claude/skills` | `claude/skills` |
| `~/.claude/commands` | `claude/commands` |
| `~/.codex/AGENTS.md` | `claude/CLAUDE.md` |

## 지침은 CLAUDE.md 한 곳에만 쓴다

공통 지침 본문은 `claude/CLAUDE.md`에만 쓴다. Claude Code는 `~/.claude/CLAUDE.md`로,
Codex는 `~/.codex/AGENTS.md`로 같은 파일을 링크해서 읽는다. 두 도구가 파일 하나를 함께 보므로
import나 복사본 없이 한 곳만 고치면 된다.

Codex는 `@경로` import를 해석하지 못한다. 그래서 import 대신 링크로 같은 파일을 읽게 한다.
지침 안에 다른 파일을 `@~/...`로 import하면 Codex는 그 내용을 읽지 못하므로, 공통 지침은 이 파일에 직접 쓴다.

프로젝트 단위 지침은 여전히 도구별로 갈린다. Claude Code는 프로젝트의 `CLAUDE.md`,
Codex는 프로젝트의 `AGENTS.md`를 읽는다.

## 새 기기에서 세팅하기

```bash
git clone https://github.com/jkchappydev/ai-config.git ~/ai-config
cd ~/ai-config
./install.sh
```

클론 위치는 어디여도 된다. `install.sh`가 실제 저장소 위치를 기준으로 링크를 건다.
`~/.claude`가 비어 있어도 되고, 그 안의 다른 내용(로그인 정보, 세션 기록, 플러그인)은 건드리지 않는다.
즉 **클론 + `./install.sh`** 만으로 지침·규칙·스킬·커맨드·플러그인이 모두 적용된다.
MCP는 기기마다 한 번씩 아래 [사용자 범위 MCP](#사용자-범위-mcp)로 등록한다.

`install.sh`는 여러 번 실행해도 안전하다. 링크 자리에 기존 실제 파일이 있으면
`~/.ai-config-backup-<시각>/`으로 옮긴 뒤 링크로 교체한다.

Windows(Git Bash)에서는 심볼릭 링크 생성에 권한이 필요하다. 개발자 모드를 켜거나,
관리자 터미널에서 아래처럼 실행한다.

```bash
MSYS=winsymlinks:nativestrict ./install.sh
```

마지막에 링크를 검증한다. 하나라도 깨져 있으면 종료코드 1로 끝나므로,
`설치 완료.`가 출력되고 종료코드가 0인지 확인하면 된다.

## 플러그인·MCP 설정 요약

- **superpowers** (브레인스토밍·계획·TDD·디버깅·코드 리뷰 작업 절차): `plugins.conf`에 등록해서 `install.sh`로 설치한다.
- **context7** (라이브러리·프레임워크 최신 공식 문서 조회): `npx`로 실행하는 MCP를 `claude mcp add -s user`로 등록한다.
- **claude-code-setup** (프로젝트에 맞는 hook·스킬·MCP 추천): `plugins.conf`에 등록해서 `install.sh`로 설치한다.
- **계정 커넥터** (Claude Docs, Notion, Google Drive, Google Calendar, Gmail): Anthropic 계정에 붙으므로 저장소에서 관리하지 않는다. 같은 계정으로 로그인하면 따라온다.
- **21st** (자연어 설명으로 UI 컴포넌트 생성): 기본 구성에 넣지 않는다. 필요하면 https://21st.dev/mcp 에서 키를 발급받아 `claude mcp add -s user`로 등록한다.

## 규칙·스킬·커맨드

### 규칙 (`claude/rules/`)

매 세션 전체가 로드되므로 짧고 항상 지켜야 하는 기준만 둔다. 특정 작업에서만 필요한 절차는 스킬로 둔다.

| 파일 | 내용 |
|---|---|
| `context7.md` | 최신 공식 문서가 실제로 필요한 작업에서만 context7을 호출하는 기준 |

### 스킬 (`claude/skills/`)

평소에는 설명만 로드되고, 작업이 설명과 맞을 때 본문을 불러온다.

| 스킬 | 용도 |
|---|---|
| `design-taste-frontend` | 웹 페이지와 화면을 만들거나 고칠 때 쓰는 프론트엔드 디자인 기준 |
| `hallmark` | 새 페이지 디자인, 디자인 감사·재설계, URL·스크린샷에서 디자인 추출 |
| `flow-diagram` | 시스템·API 동작 흐름을 Cobalt 테마 인라인 SVG Artifact로 작성 |

### 커맨드 (`claude/commands/`)

| 커맨드 | 용도 |
|---|---|
| `/gh-push` | 현재 프로젝트를 GitHub에 업로드하고 main 브랜치로 푸시 |
| `/new-project-nextjs` | Next.js 프로젝트를 생성하고 검증한 뒤 GitHub에 업로드 |
| `/new-project-springboot` | Spring Boot 프로젝트를 생성하고 검증한 뒤 GitHub에 업로드 |

## 플러그인

플러그인 본체는 저장소에 담지 않는다. `installed_plugins.json`에 기기별 절대경로가 들어가고
`cache/`가 내려받은 파일 20MB라, 그대로 공유하면 다른 기기에서 깨진다.

대신 **무엇이 필요한지만** `claude/plugins.conf`에 적고, `install.sh`가 `claude` CLI로 설치한다.

```
marketplace claude-plugins-official anthropics/claude-plugins-official

plugin superpowers@claude-plugins-official
plugin claude-code-setup@claude-plugins-official
```

이미 등록·설치돼 있으면 건너뛴다. `claude` CLI를 못 찾으면 경고만 남기고 링크 설치는 그대로 끝내므로,
Claude Code를 나중에 깔았다면 `./install.sh`를 다시 실행하면 된다.

플러그인을 추가할 때는 **두 곳을 같이 고친다.** `plugins.conf`는 설치 여부를,
`claude/settings.json`의 `enabledPlugins`는 켜짐 여부를 정한다. 한쪽만 고치면
설치는 됐는데 꺼져 있거나, 켜라는 설정만 있고 실체가 없는 상태가 된다.

`claude plugin marketplace add`, `claude plugin install`로 직접 설치하면 CLI가 `settings.json`의
`extraKnownMarketplaces`와 `enabledPlugins`를 자동으로 채운다. 이때는 `plugins.conf`만 손으로 맞추면 된다.

### 설치 중인 플러그인

| 플러그인 | 마켓플레이스 | 용도 | 포함 구성 | 기기별 준비 | 홈페이지 |
|---|---|---|---|---|---|
| `superpowers` | `claude-plugins-official` | 브레인스토밍, 계획, TDD, 디버깅, 코드 리뷰 등 작업 절차 | 스킬, hook | 없음 | [github.com/obra/superpowers](https://github.com/obra/superpowers) |
| `claude-code-setup` | `claude-plugins-official` | 코드베이스를 분석해 hook, 스킬, MCP, 서브에이전트 추천 (읽기 전용) | 스킬 | 없음 | [claude-plugins-official/plugins/claude-code-setup](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup) |

## MCP

MCP는 등록 위치에 따라 적용 범위가 다르다.

| 방식 | 저장 위치 | 적용 범위 | 공유 |
|---|---|---|---|
| 계정 커넥터 | Anthropic 계정 | 로그인한 모든 기기 | 계정 로그인으로 따라옴 |
| 플러그인 | 플러그인 폴더 안의 `.mcp.json` | 모든 프로젝트 | `plugins.conf`로 공유 |
| 사용자 범위 (`claude mcp add -s user`) | `~/.claude.json` | 모든 프로젝트 | 공유 안 됨, 기기마다 등록 |
| 프로젝트 범위 | 프로젝트 루트의 `.mcp.json` | 그 프로젝트만 | 프로젝트 저장소로 공유 |

이 저장소에는 `.mcp.json`을 두지 않는다. `~/.claude/.mcp.json`은 `~/.claude` 폴더를 프로젝트로 열 때만 읽히므로 전역 설정으로 동작하지 않는다.
같은 서버를 두 방식으로 등록하면 도구가 중복으로 잡히므로 한 곳에만 등록한다.

### 계정 커넥터 MCP

claude.ai 계정에 연결한 커넥터는 설정 파일이 아니라 Anthropic 계정에 저장된다. 이 저장소에서 관리할 수 없고,
새 기기에서도 같은 계정으로 로그인하면 그대로 따라온다. 추가와 해제는 claude.ai의 커넥터 설정에서 한다.
`claude mcp list`에는 이름 앞에 `claude.ai`가 붙어 표시된다.

| MCP | 용도 | 연결 주소 |
|---|---|---|
| `Claude Docs` | 함께 보고 고치는 문서 작성 | `https://api.anthropic.com/v1/pages/mcp` |
| `Notion` | Notion 페이지·데이터베이스 조회와 작성 | `https://mcp.notion.com/mcp` |
| `Google Drive` | Drive 파일 조회, Docs·Sheets·Slides 작성 | `https://drivemcp.googleapis.com/mcp/v1` |
| `Google Calendar` | 일정 조회와 등록 | `https://calendarmcp.googleapis.com/mcp/v1` |
| `Gmail` | 메일 조회와 작성 | `https://gmailmcp.googleapis.com/mcp/v1` |

### 사용자 범위 MCP

사용자 범위 MCP는 `~/.claude.json`에 등록한다. 이 파일은 저장소 밖에 있어 API 키가 Git에 올라가지 않는다.
새 기기에서는 아래 명령을 한 번 실행하고 Claude Code를 다시 시작한다.

| MCP | 용도 | 연결 주소 | 키 발급 홈페이지 | 비용 | 홈페이지 |
|---|---|---|---|---|---|
| `context7` | 라이브러리·프레임워크 최신 공식 문서 조회 | `npx -y @upstash/context7-mcp@latest` (로컬 실행) | 필요 없음 | 무료 | [context7.com](https://context7.com) |
| `21st` | 자연어 설명으로 UI 컴포넌트 생성 | `https://21st.dev/api/mcp` | https://21st.dev/mcp | 무료 키 제공 | [21st.dev](https://21st.dev), [github.com/21st-dev/magic-mcp](https://github.com/21st-dev/magic-mcp) |

`context7`은 Node.js가 설치된 기기에서 아래 명령으로 등록한다.

```bash
claude mcp add -s user context7 -- npx -y @upstash/context7-mcp@latest
```

`21st`은 기본 구성에 넣지 않는다. 필요한 기기에서 아래 순서로 등록한다.

1. https://21st.dev/mcp 에 접속해 로그인한다.
2. 페이지에서 API 키를 생성하고 복사한다.
3. 아래 명령으로 등록한다.

```bash
claude mcp add -s user --transport http 21st https://21st.dev/api/mcp --header "x-api-key: <발급받은 키>"
```

`-s user`를 빠뜨리면 현재 프로젝트에만 등록된다. 등록 결과는 `claude mcp list`에서 `✔ Connected`로 확인한다.

등록 후 `~/.claude.json`에 들어가는 형태는 `claude/mcp.example.json`에 키를 지운 예시로 둔다.
이 파일은 참고용이며 `install.sh`가 링크하지 않는다. 실제 키는 저장소에 넣지 않는다.
특정 프로젝트에서만 쓰려면 이 파일을 `.mcp.json`으로 이름을 바꿔 프로젝트 루트에 두고 키를 채운다.
`.mcp.json`은 프로젝트 저장소에 함께 올라가므로, 키를 채운 파일은 커밋하지 않는다.

### Codex

플러그인과 `~/.claude.json`은 Claude Code 전용이다. Codex에서 같은 MCP를 쓰려면 그 기기의 `~/.codex/config.toml`에 직접 추가한다.

## 기기 전용으로 두는 것 (git 제외)

| 경로 | 내용 |
|---|---|
| `~/.claude/rules/*.local.md` | 그 기기에서만 적용할 규칙. 매 세션 자동 로드됨 |
| `~/.claude/references/` | 서버 SSH 접속 정보 등 기기 전용 참고자료 |
| `~/.claude/skills/synced/` | Claude Code가 만드는 동기화 캐시 |
| `~/.codex/config.toml` | 모델·프로젝트 신뢰 설정. 기기별 경로가 들어가서 공유하지 않음 |
| `~/.claude.json` | 사용자 범위 MCP와 API 키. Claude Code가 관리하므로 `claude mcp add`로만 수정 |

## 도구가 관리하므로 추적하지 않는 것

`~/.claude` 아래의 `.credentials.json`, `projects/`, `history.jsonl`, `sessions/`,
`plugins/`, `backups/`, 각종 캐시는 링크 대상이 아니므로 애초에 저장소에 들어오지 않는다.
`~/.codex`의 `auth.json`, `*.sqlite`, `logs/`도 마찬가지다.
