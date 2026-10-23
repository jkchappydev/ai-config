#!/usr/bin/env bash
# ~/.claude, ~/.codex 의 설정 파일을 이 저장소로 심볼릭 링크한다.
# 여러 번 실행해도 안전하며, 기존 실제 파일은 백업 후 교체한다.
# 저장소를 어느 경로에 클론해도 동작한다 (~/ai-config 호환 링크를 함께 만든다).
set -euo pipefail

# 심볼릭 링크를 통해 실행해도 실제 저장소 위치를 잡도록 -P 사용
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP="$HOME/.ai-config-backup-$(date +%Y%m%d-%H%M%S)"
COMPAT="$HOME/ai-config"

# 저장소 경로 : 홈 기준 링크 경로
LINKS=(
  "claude/CLAUDE.md:.claude/CLAUDE.md"
  "claude/settings.json:.claude/settings.json"
  "claude/statusline-command.sh:.claude/statusline-command.sh"
  "claude/rules:.claude/rules"
  "claude/skills:.claude/skills"
  "claude/commands:.claude/commands"
  "codex/AGENTS.md:.codex/AGENTS.md"
)

FAILED=0

link_one() {
  local src="$REPO/$1" dest="$HOME/$2"

  if [ ! -e "$src" ]; then
    echo "건너뜀 (저장소에 없음): $1"
    return
  fi

  # 이미 같은 곳을 가리키는 링크면 그대로 둠
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "이미 연결됨: ~/$2"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  # 기존 파일·디렉터리·잘못된 링크는 백업으로 옮김
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP/$(dirname "$2")"
    mv "$dest" "$BACKUP/$2"
    echo "백업: ~/$2 -> $BACKUP/$2"
  fi

  ln -s "$src" "$dest"
  echo "연결: ~/$2 -> $src"
}

# CLAUDE.md 는 지침 본문을 @~/ai-config/codex/AGENTS.md 로 import 한다.
# 저장소가 ~/ai-config 가 아닌 곳에 있어도 그 경로가 해석되도록 호환 링크를 만든다.
link_compat() {
  if [ "$REPO" = "$COMPAT" ]; then
    echo "호환 링크 불필요 (저장소가 이미 ~/ai-config)"
    return
  fi

  if [ -L "$COMPAT" ] && [ "$(readlink "$COMPAT")" = "$REPO" ]; then
    echo "이미 연결됨: ~/ai-config"
    return
  fi

  # 실제 디렉터리가 있으면 사용자의 다른 클론일 수 있으므로 지우지 않고 백업
  if [ -e "$COMPAT" ] || [ -L "$COMPAT" ]; then
    mkdir -p "$BACKUP"
    mv "$COMPAT" "$BACKUP/ai-config"
    echo "백업: ~/ai-config -> $BACKUP/ai-config"
  fi

  ln -s "$REPO" "$COMPAT"
  echo "연결: ~/ai-config -> $REPO"
}

# 플러그인은 절대경로와 내려받은 파일 20MB 가 섞여 있어 저장소에 담지 않는다.
# 대신 claude/plugins.conf 에 무엇이 필요한지만 적고 여기서 claude CLI 로 설치한다.
bootstrap_plugins() {
  local conf="$REPO/claude/plugins.conf"
  local kind name source have_mkt have_plg

  if [ ! -f "$conf" ]; then
    echo "  건너뜀 (claude/plugins.conf 없음)"
    return
  fi

  if ! command -v claude >/dev/null 2>&1; then
    echo "  claude CLI 를 찾을 수 없어 건너뜀 — Claude Code 설치 후 ./install.sh 를 다시 실행한다."
    return
  fi

  have_mkt="$(claude plugin marketplace list 2>/dev/null </dev/null || true)"
  have_plg="$(claude plugin list 2>/dev/null </dev/null || true)"

  while read -r kind name source; do
    case "$kind" in
      ''|\#*) continue ;;

      marketplace)
        if printf '%s' "$have_mkt" | grep -q -- "$name"; then
          echo "  이미 등록됨: $name"
        elif claude plugin marketplace add "$source" </dev/null; then
          echo "  마켓플레이스 등록: $name ($source)"
        else
          echo "  마켓플레이스 등록 실패: $name ($source)"
          FAILED=1
        fi
        ;;

      plugin)
        if printf '%s' "$have_plg" | grep -q -- "$name"; then
          echo "  이미 설치됨: $name"
        elif claude plugin install "$name" </dev/null; then
          echo "  플러그인 설치: $name"
        else
          echo "  플러그인 설치 실패: $name"
          FAILED=1
        fi
        ;;

      *)
        echo "  알 수 없는 항목 무시: $kind"
        ;;
    esac
  done < "$conf"
}

for pair in "${LINKS[@]}"; do
  link_one "${pair%%:*}" "${pair##*:}"
done
link_compat

echo
echo "=== 플러그인 ==="
bootstrap_plugins

echo
echo "=== 연결 상태 ==="
for pair in "${LINKS[@]}"; do
  dest="$HOME/${pair##*:}"
  if [ -L "$dest" ] && [ -e "$dest" ]; then
    printf '  %-34s -> %s\n' "~/${pair##*:}" "$(readlink "$dest")"
  elif [ -L "$dest" ]; then
    printf '  %-34s 링크가 깨짐!\n' "~/${pair##*:}"
    FAILED=1
  else
    printf '  %-34s (링크 아님)\n' "~/${pair##*:}"
    FAILED=1
  fi
done

# CLAUDE.md 안의 @~/... import 가 실제로 해석되는지 확인한다.
# 링크가 다 걸려도 이 import 가 깨지면 공통 지침이 조용히 통째로 누락된다.
echo
echo "=== 지침 import 확인 ==="
while read -r imp; do
  target="${imp/#@\~/$HOME}"
  if [ -e "$target" ]; then
    printf '  %-34s OK\n' "$imp"
  else
    printf '  %-34s 대상 없음!\n' "$imp"
    FAILED=1
  fi
done < <(grep -o '^@~[^[:space:]]*' "$REPO/claude/CLAUDE.md" || true)

echo
if [ "$FAILED" -ne 0 ]; then
  echo "설치 미완료 — 위의 실패 항목을 확인한다."
  exit 1
fi
echo "설치 완료."
