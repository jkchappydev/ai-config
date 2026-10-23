---
description: 새 프로젝트를 생성하고 검증한 뒤 GitHub에 업로드
argument-hint: [프로젝트명] [--stack <스택>] [--private] [--no-push]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Skill, WebFetch, WebSearch
---

새 프로젝트를 생성하고 GitHub에 업로드한다.

전달된 인자: `$ARGUMENTS`

## 1. 프로젝트 설정

전달받은 인자를 기준으로 프로젝트를 생성한다.

- 프로젝트명: 첫 번째 인자를 사용하고, 없으면 현재 디렉터리에 생성한다.
- `--stack`: 사용할 기술 스택을 지정한다. 기본값은 `react-spring`이다.
- `--private`: GitHub 저장소를 비공개로 생성한다. 기본값은 public이다.
- `--no-push`: GitHub 업로드 없이 로컬 프로젝트 생성과 검증까지만 진행한다.

### 지원 스택

| 스택 | 구성 |
| --- | --- |
| `react-spring` (기본) | React + TypeScript + Vite / Spring Boot + Java + Gradle |
| `react` | React + TypeScript + Vite |
| `spring` | Spring Boot + Java + Gradle |
| `next` | Next.js + TypeScript |

위 목록에 없는 기술 스택도 지정할 수 있다. 구성이 불분명한 경우에는 사용자에게 확인한다.

## 2. 기존 파일 확인

프로젝트를 생성할 디렉터리를 먼저 확인한다.

- 기존 파일이나 Git 저장소가 있는지 확인한다.
- 이미 파일이 있다면 임의로 덮어쓰지 않고 사용자에게 확인한다.
- 기존 프로젝트인 경우 필요한 부분만 추가하거나 수정한다.

## 3. 기술 스택 및 버전 확인

프로젝트 생성 전에 사용할 기술 스택의 최신 안정 버전을 확인한다.

- Context7을 통해 공식 설정 방법과 최신 문서를 확인한다.
- npm 패키지는 `npm view`로 버전을 확인한다.
- Spring Boot는 Spring Initializr를 통해 버전을 확인한다.
- Node.js와 Java는 호환되는 LTS 버전을 우선 사용한다.
- SNAPSHOT이나 개발 중인 버전은 사용하지 않는다.
- 현재 설치된 개발 환경과의 호환성도 확인한다.

버전이나 설정 정보를 확인하지 못했다면 해당 내용을 알려준다.

## 4. 프로젝트 생성

기술 스택에 맞는 공식 프로젝트 생성 도구를 사용한다.

- React: `create-vite`
- Spring Boot: Spring Initializr
- Next.js: `create-next-app`

`react-spring` 구성은 아래 구조로 생성한다.

```text
프로젝트명/
├── frontend/
├── backend/
├── Makefile
├── README.md
├── AGENTS.md
├── CLAUDE.md
└── .gitignore
```

추가로 아래 내용을 구성한다.

- 프런트엔드에서 `/api` 요청을 백엔드로 전달하는 프록시 설정
- 백엔드 상태 확인용 API
- 프런트엔드와 백엔드 연결 확인 화면
- `make setup`, `make dev`, `make verify`, `make smoke` 명령
- 개발 서버 종료 시 관련 프로세스도 함께 종료되도록 설정

단일 스택 프로젝트라면 불필요한 프록시나 연동 기능은 추가하지 않는다.

## 5. 기본 파일 작성

프로젝트에 필요한 기본 파일을 작성한다.

- `README.md`: 프로젝트 구성, 사용한 기술과 버전, 설치 및 실행 방법
- `AGENTS.md`: 프로젝트 개발 지침
- `CLAUDE.md`: `@AGENTS.md` 한 줄로 작성
- `.gitignore`: 프로젝트에 맞는 제외 항목 설정

`.gitignore`에는 `node_modules/`, `build/`, `dist/`, `.gradle/` 등을 포함하고, 프로젝트에서 생성되는 불필요한 파일이 Git에 올라가지 않도록 한다.

문서는 한국어로 작성한다.

## 6. 프로젝트 검증

프로젝트 생성이 끝나면 실제로 설치, 테스트, 빌드를 진행한다.

```sh
make setup && make verify && make smoke
```

- 의존성 설치 확인
- 정적 검사 및 타입 검사
- 프런트엔드 빌드
- 백엔드 테스트 및 빌드
- API 호출 및 프런트엔드 연동 확인

단일 스택 프로젝트에서는 해당하는 항목만 검증한다.

오류가 발생하면 가능한 범위에서 수정하고 다시 검증한다. 해결되지 않은 오류나 실행하지 못한 항목은 결과에 함께 안내한다.

## 7. GitHub 푸시

검증이 끝나면 아래 스크립트를 실행한다.

```sh
bash ~/.claude/scripts/gh-push.sh -m "초기 프로젝트 구성"
```

- `--private` 옵션이 전달되었다면 스크립트에도 함께 전달한다.
- `--no-push` 옵션이 있다면 GitHub 업로드를 진행하지 않는다.
- Git 초기화, 커밋, 저장소 생성 및 푸시는 스크립트에서 처리한다.
- 기본 브랜치는 `main`으로 설정한다.

## 8. 작업 결과 안내

작업이 끝나면 아래 내용을 간단히 알려준다.

- 생성한 프로젝트 구조 및 기술 스택
- 사용한 주요 버전
- 프로젝트 실행 방법
- 테스트 및 빌드 결과
- GitHub 저장소 URL (`--no-push`인 경우 제외)

## 주의사항

- 요청하지 않은 DB, Redis, Kafka, 인증, 배포 환경 등은 임의로 추가하지 않는다.
- 기존 파일은 사용자 확인 없이 덮어쓰지 않는다.
- 비즈니스 기능을 구현하는 경우 Controller → Service → Repository 구조와 DTO를 사용한다.
- 단순한 API에는 불필요한 계층을 추가하지 않는다.
- GitHub 업로드 중 오류가 발생하면 강제 푸시하거나 임의로 우회하지 않고 원인을 알려준다.
- 커밋 메시지는 제목 한 줄로 작성하고 공동작성자 표기는 추가하지 않는다.