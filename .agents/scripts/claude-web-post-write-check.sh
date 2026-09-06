#!/usr/bin/env bash
# Claude Code PostToolUse hook — format the file that was just written, then run
# the project's own checks.
#
# Exits 2 on failure with the output on stderr, because that is the only channel
# a PostToolUse hook has to Claude: stdout from an exit-0 hook goes to the debug
# log and is never shown. The hook entry sets asyncRewake, so the checks run in
# the background and only interrupt the model when they actually fail.
#
# Formatting is scoped to the edited file so the hook cannot rewrite files the
# agent did not touch. The repo's own `check`/`lint` scripts stay project-wide —
# there is no portable way to scope them — but one that rewrites the repo (a
# `--write`/`--fix` script such as `biome check --write .`) is skipped for the
# same reason: the per-file format above already covered the edited file.
set -uo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
FILE_PATH="$(jq -r '.tool_input.file_path // empty')"

case "$FILE_PATH" in
  "$PROJECT_ROOT"/*)
    RELATIVE_FILE="${FILE_PATH#"$PROJECT_ROOT"/}"
    ;;
  *)
    exit 0
    ;;
esac

# The declarative gates in settings.json are approximate; this is the
# authoritative list.
case "$RELATIVE_FILE" in
  *.js|*.jsx|*.mjs|*.cjs|*.ts|*.tsx|*.mts|*.cts|*.svelte|*.vue|*.astro|*.css) ;;
  *) exit 0 ;;
esac

cd "$PROJECT_ROOT" || exit 1

failed=0
report=""

clip() {
  local text="$1" total
  total="$(printf '%s\n' "$text" | wc -l | tr -d ' ')"
  if ((total > 30)); then
    printf '%s\n' "$text" | head -10
    printf '... (%d lines elided) ...\n' "$((total - 30))"
    printf '%s\n' "$text" | tail -20
  else
    printf '%s\n' "$text"
  fi
}

run_step() {
  local label="$1"
  shift
  local output rc
  output="$("$@" 2>&1)"
  rc=$?
  if ((rc != 0)); then
    failed=1
    report+="${label} failed (exit ${rc}):"$'\n'"$(clip "$output")"$'\n\n'
  fi
}

# Runs a package.json script project-wide. Returns 1 without running when the
# repo doesn't define it, or when it would rewrite files across the repo.
run_project_script() {
  local label="$1" name="$2" body
  body="$(jq -r --arg n "$name" '.scripts[$n] // ""' package.json 2>/dev/null)"
  [[ -n "$body" ]] || return 1
  case "$body" in
    *--write*|*--fix*) return 1 ;;
  esac
  run_step "$label" pnpm run "$name"
}

# Format the one file, using whichever formatter this repo actually declares —
# by config file, or by what its own `format` script shells out to. Anything
# else formats nothing rather than falling back to a repo-wide `pnpm format`.
format_script="$(jq -r '.scripts.format // ""' package.json 2>/dev/null)"
formatter=""
if [[ -f biome.json || -f biome.jsonc ]]; then
  formatter="biome"
elif compgen -G ".prettierrc*" >/dev/null || compgen -G "prettier.config.*" >/dev/null; then
  formatter="prettier"
else
  case "$format_script" in
    *biome*) formatter="biome" ;;
    *prettier*) formatter="prettier" ;;
    "vp "*|*" vp "*) formatter="vp" ;;
  esac
fi

case "$formatter" in
  biome) run_step "Biome ($RELATIVE_FILE)" pnpm exec biome check --write "$RELATIVE_FILE" ;;
  prettier) run_step "Prettier ($RELATIVE_FILE)" pnpm exec prettier --write "$RELATIVE_FILE" ;;
  vp) run_step "Format ($RELATIVE_FILE)" pnpm exec vp fmt "$RELATIVE_FILE" ;;
esac

run_project_script "Type check" check ||
  for name in check-types lint:types typecheck check:types; do
    run_project_script "Type check" "$name" && break
  done
run_project_script "Lint" lint || true

if ((failed)); then
  printf 'Post-write checks failed after editing %s\n\n%s' "$RELATIVE_FILE" "$report" >&2
  exit 2
fi
