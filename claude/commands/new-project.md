---
description: 새 프로젝트를 원하는 스택으로 생성하고 검증한 뒤 GitHub에 올린다
argument-hint: [프로젝트명] [--stack <스택>] [--private] [--no-push]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Skill, WebFetch, WebSearch
---

새 프로젝트를 생성하고 GitHub까지 올린다. 전달된 인자: `$ARGUMENTS`

## 인자

- **첫 번째 위치 인자**: 프로젝트명 겸 디렉터리명. 생략하면 현재 디렉터리에 만든다
- `--stack <스택>`: 기술 스택. 생략하면 `react-spring`
- `--private`: 비공개 레포로 생성 (기본 public)
- `--no-push`: GitHub 업로드를 건너뛰고 로컬 생성·검증까지만

### 스택 프리셋

| 값 | 구성 |
| --- | --- |
| `react-spring` (기본) | `frontend/` React+TS+Vite, `backend/` Spring Boot+Java+Gradle Kotlin DSL, `/api` 프록시로 연결 |
| `react` | React+TS+Vite 단독 |
| `spring` | Spring Boot+Java+Gradle Kotlin DSL 단독 |
| `next` | Next.js+TypeScript 단독 |

프리셋에 없는 값(`--stack "FastAPI + React"` 등)은 자유 입력으로 해석한다. 모호하면 시작 전에 한 번 확인한다.

## 순서

### 1. 기존 작업 확인

대상 디렉터리에 파일이나 git 저장소가 있는지 먼저 본다. 있으면 **덮어쓰지 말고** 사용자에게 확인한다. 기존 프로젝트라면 부족한 부분만 보완한다.

### 2. 최신 버전 확인 (생략 금지)

전역 지침에 따라 **요청 시점** 기준으로 조회한다. 전역 문서나 기억 속 버전을 최신이라고 가정하지 않는다.

- `context7-mcp` 스킬로 해당 스택의 최신 초기 설정 문서를 확인한다. MCP가 없으면 공개 Context7 문서를 보고, 조회 못 한 항목은 공식 문서로 보완하되 그 한계를 사용자에게 밝힌다
- npm 레지스트리(`npm view <pkg> version`)와 Spring Initializr 메타데이터(`curl -s https://start.spring.io/metadata/client`)로 안정 버전을 확인한다
- prerelease·SNAPSHOT은 고르지 않는다. Node·Java는 호환되는 지원 중 LTS를 쓰고 이미 설치된 환경도 고려한다
- **조회하지 않았는데 확인했다고 말하지 않는다**

### 3. 스캐폴딩

공식 템플릿을 우선한다 — `create-vite`의 `react-ts`, Spring Initializr, `create-next-app`. 잠금 파일과 Gradle Wrapper를 포함하고, 실제 선택한 버전을 README에 남긴다.

`react-spring`처럼 프런트·백엔드가 함께인 스택은 아래를 구성한다.

- `/api` 개발 프록시와 최소 health API, 연결 확인 화면
- `make setup / dev / verify / smoke` — 개발 프로세스는 종료 시 함께 정리한다
- 단일 스택이면 프록시·연동 확인은 빼고 그 스택에 맞는 명령만 제공한다

### 4. 문서 작성 (한국어)

- `README.md`: 환경 요구사항, 설치, 실행, 검증 방법, 확인한 버전 표
- `AGENTS.md`와 `CLAUDE.md`(`@AGENTS.md` 한 줄): 프로젝트 지침
- `.gitignore`: 스택에 맞게. `node_modules/`, `build/`, `dist/`, `.gradle/`는 반드시 포함
- `PROGRESS.md`: `# 진행상황` + 목적 인용구, `## 완료된 작업`, `## 다음 진행 예정`
- `docs/worklog/<오늘 날짜>.md`: 무엇을 왜 그렇게 만들었는지, 선택한 버전과 근거

### 5. 검증

실제로 실행한다. 정적 검사·타입 검사·빌드, 백엔드 테스트·빌드, HTTP 연동 확인까지 한다.

```sh
make setup && make verify && make smoke
```

**실패나 미실행 항목을 숨기지 않는다.** 원인과 함께 보고한다.

### 6. GitHub 업로드

`--no-push`가 없으면 실행한다. 커밋 메시지는 `-m`으로 직접 넘긴다.

```sh
bash ~/.claude/scripts/gh-push.sh -m "초기 프로젝트 구성"
```

`--private`를 받았으면 그대로 넘긴다. 이 스크립트가 git 초기화 → main 브랜치 → 작성자 고정 → 커밋 → 레포 생성 → push → 기본 브랜치 지정까지 처리한다.

### 7. 결과 보고

주요 구성, 선택한 버전, 실행 명령, **검증 결과**, 레포 URL, 기록한 파일 위치를 간결하게 알린다.

## 주의

- Kafka, Redis, DB, 인증, 배포는 **프로젝트 이름만 보고 추가하지 않는다.** 실제 요구가 있을 때 구성한다
- 통상적이고 되돌릴 수 있는 설정은 재확인 없이 진행한다. 다만 기존 파일 덮어쓰기는 반드시 확인받는다
- 비즈니스 기능이 생기면 Controller → Service → Repository와 DTO를 쓴다. health API처럼 로직이 없는 곳에 빈 계층을 만들지 않는다
- 스크립트가 중단되면 원인을 그대로 전달한다. 임의로 우회하지 않는다
