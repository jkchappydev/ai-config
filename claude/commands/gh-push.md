---
description: 현재 프로젝트를 GitHub에 업로드하고 main 브랜치로 푸시
argument-hint: [--private] [--name <레포이름>] [-m "커밋 메시지"]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

현재 프로젝트를 내 GitHub 계정에 업로드한다.

전달된 인자: `$ARGUMENTS`

## 1. Git 상태 확인

먼저 현재 변경사항, 원격 저장소, 최근 커밋 내역을 확인한다.

```sh
git status --short 2>&1 | head -30; echo "---"; git remote -v; echo "---"; git log --oneline -5 2>&1
```

## 2. .gitignore 확인

`.gitignore` 파일을 확인하고 프로젝트에 맞게 필요한 항목을 추가한다.

특히 `node_modules/`, `build/`, `dist/`, `.gradle/` 등 빌드 결과물이나 불필요한 파일이 Git에 포함되지 않도록 확인한다.

## 3. GitHub 푸시

`.gitignore` 확인이 끝나면 아래 스크립트를 실행한다.

```sh
bash ~/.claude/scripts/gh-push.sh $ARGUMENTS
```

- 전달받은 인자는 그대로 사용한다.
- 커밋 메시지가 지정되지 않았다면 작업 내용에 맞게 한 줄로 작성하고 `-m` 옵션으로 전달한다.
- 저장소가 없으면 새로 생성하고, 이미 있으면 기존 저장소를 사용한다.
- 기본 브랜치는 `main`으로 설정한다.
- 변경사항이 없으면 추가 커밋 없이 푸시한다.

## 4. 작업 결과 안내

푸시가 끝나면 아래 내용을 간단히 알려준다.

- GitHub 저장소 URL
- 커밋 메시지
- 기본 브랜치

## 주의사항

- 기존 저장소와 커밋 내역은 유지한다.
- 오류가 발생하면 임의로 강제 푸시하거나 우회하지 않고 원인을 알려준다.
- 커밋 메시지는 제목 한 줄로 작성하고 공동작성자 표기는 추가하지 않는다.
- 열려 있는 PR이나 아직 병합되지 않은 관련 브랜치가 있으면 진행 전에 확인받는다.
