---
description: Spring Boot 프로젝트를 생성하고 검증한 뒤 GitHub에 업로드
argument-hint: [프로젝트명] [--private] [--no-push]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Skill, WebFetch, WebSearch
---

Spring Boot 프로젝트를 생성하고 GitHub에 업로드한다.

전달된 인자: `$ARGUMENTS`

## 1. 프로젝트 설정

전달받은 인자를 기준으로 프로젝트를 생성한다.

- 프로젝트명: 첫 번째 인자를 사용하고, 없으면 현재 디렉터리에 생성한다.
- `--private`: GitHub 저장소를 비공개로 생성한다. 기본값은 public이다.
- `--no-push`: GitHub 업로드 없이 로컬 프로젝트 생성과 검증까지만 진행한다.

이 커맨드는 Spring Boot 프로젝트만 생성한다. 다른 기술 스택을 요청받으면 해당 스택의 생성 커맨드를 사용한다.

## 2. 기존 파일 확인

프로젝트를 생성할 디렉터리를 먼저 확인한다.

- 기존 파일이나 Git 저장소가 있는지 확인한다.
- 이미 파일이 있다면 임의로 덮어쓰지 않고 사용자에게 확인한다.
- 기존 프로젝트인 경우 필요한 부분만 추가하거나 수정한다.

## 3. 버전 확인

프로젝트 생성 전에 사용할 버전을 확인한다.

- Context7에서 Spring Boot 공식 설정 방법과 최신 문서를 확인한다.
- Spring Initializr 메타데이터에서 최신 안정 버전을 확인한다.
- Java는 해당 Spring Boot 버전과 호환되는 LTS 버전을 사용한다.
- SNAPSHOT, milestone, RC 버전은 사용하지 않는다.
- 현재 설치된 개발 환경과의 호환성도 확인한다.

버전이나 설정 정보를 확인하지 못했다면 해당 내용을 알려준다.

## 4. 프로젝트 생성

공식 생성 도구인 Spring Initializr를 사용한다.

- 빌드 도구는 Gradle Kotlin DSL을 사용한다.
- Gradle Wrapper를 포함한다.
- 의존성은 요청받은 범위만 선택한다. 기본은 Spring Web으로 한다.

생성 후 구조는 아래와 같다.

```text
프로젝트명/
├── src/
│   ├── main/java/
│   ├── main/resources/
│   └── test/java/
├── build.gradle.kts
├── gradlew
├── Makefile
├── README.md
├── AGENTS.md
├── CLAUDE.md
└── .gitignore
```

## 5. 기본 파일 작성

프로젝트에 필요한 기본 파일을 작성한다.

- `README.md`: 프로젝트 구성, 사용한 버전, 설치 및 실행 방법
- `AGENTS.md`: 프로젝트 개발 지침
- `CLAUDE.md`: `@AGENTS.md` 한 줄로 작성
- `Makefile`: `make setup`, `make dev`, `make verify` 명령 제공
- `.gitignore`: `build/`, `.gradle/`, IDE 설정, 환경변수 파일 등 제외

상태 확인용 API를 하나 추가하고, 대응하는 테스트를 함께 작성한다.

문서는 한국어로 작성한다.

## 6. 프로젝트 검증

프로젝트 생성이 끝나면 실제로 테스트와 빌드를 진행한다.

```sh
make setup && make verify
```

- 의존성 해결 확인
- 테스트 실행
- 빌드 수행
- 애플리케이션 기동 및 상태 확인 API 응답 확인

오류가 발생하면 가능한 범위에서 수정하고 다시 검증한다. 해결되지 않은 오류나 실행하지 못한 항목은 결과에 함께 안내한다.

검증을 위해 기동한 프로세스는 확인이 끝나면 종료한다.

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

- 생성한 프로젝트 구조
- 사용한 주요 버전
- 프로젝트 실행 방법
- 테스트 및 빌드 결과
- GitHub 저장소 URL (`--no-push`인 경우 제외)

## 주의사항

- 요청하지 않은 DB, Redis, Kafka, 인증, 배포 환경 등은 임의로 추가하지 않는다.
- 기존 파일은 사용자 확인 없이 덮어쓰지 않는다.
- 비즈니스 기능을 구현하는 경우 Controller → Service → Repository 구조와 DTO를 사용한다.
- 단순한 API에는 불필요한 계층을 추가하지 않는다.
- 프런트엔드가 필요한 경우 별도 스택의 생성 커맨드를 사용하고, 이 커맨드에서 함께 생성하지 않는다.
- GitHub 업로드 중 오류가 발생하면 강제 푸시하거나 임의로 우회하지 않고 원인을 알려준다.
- 커밋 메시지는 제목 한 줄로 작성하고 공동작성자 표기는 추가하지 않는다.
