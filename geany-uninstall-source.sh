#!/usr/bin/env bash
# DESC: Uninstall Geany built from source to ~/.local by the provided installer script.
# SAFE: Supports --dry-run; prompts before destructive steps; only removes expected files.

set -euo pipefail

# ---- Colors ----
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

say() { echo -e "$*"; }
run() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    eval "$@"
  fi
}

ask_yes_no() {
  local prompt="$1" ans
  while true; do
    read -rp "$prompt [y/n]: " ans
    case "${ans,,}" in
      y|yes) return 0 ;;
      n|no)  return 1 ;;
      *) say "${RED}Please enter y or n.${NC}" ;;
    esac
  done
}

header() {
  clear || true
  say "${CYAN}=========================================================${NC}"
  say "${CYAN}                 GEANY SOURCE UNINSTALLER                 ${NC}"
  say "${CYAN}=========================================================${NC}"
  $DRY_RUN && say "${YELLOW}Running in DRY RUN mode — no changes will be made.${NC}"
  echo
}

# ---- Targets we expect from the installer ----
USER_BIN="$HOME/.local/bin/geany"
USER_LIB_DIR="$HOME/.local/lib/geany"
USER_INCLUDE_DIR="$HOME/.local/include/geany"
USER_SHARE_DIR="$HOME/.local/share/geany"
USER_PKGCONFIG_DIR="$HOME/.local/lib/pkgconfig"
USER_APPS_DIR="$HOME/.local/share/applications"
DESKTOP_FILES=("$USER_APPS_DIR/geany.desktop" "$USER_APPS_DIR/geany-2.1.desktop")

CONFIG_DIR="$HOME/.config/geany"
BUILD_GLOBS=("$HOME/build-geany-"*)

GLOBAL_SYMLINK="/usr/local/bin/geany"

# PATH lines that may have been added by the installer
PATH_LINES=('export PATH="$HOME/.local/bin:$PATH"')

remove_files() {
  local paths=("$@")
  for p in "${paths[@]}"; do
    [[ -e "$p" || -L "$p" ]] || continue
    run "rm -rf -- '$p'"
  done
}

remove_matching() {
  local dir="$1" pattern="$2"
  if [[ -d "$dir" ]]; then
    # shellcheck disable=SC2044
    for f in $(find "$dir" -maxdepth 1 -type f -name "$pattern" 2>/dev/null); do
      run "rm -f -- '$f'"
    done
  fi
}

remove_line_from_shellrc() {
  local line="$1" file="$2"
  [[ -f "$file" ]] || return 0
  if grep -Fq "$line" "$file"; then
    if $DRY_RUN; then
      echo "[dry-run] sed -i '/$(printf '%s' "$line" | sed 's/[^^]/[&]/g; s/\^/\\^/g')/d' '$file'"
    else
      # remove exact line occurrences
      sed -i "\|^$line$|d" "$file"
    fi
  fi
}

refresh_desktop_cache() {
  # Update user’s desktop DB if available
  if command -v update-desktop-database >/dev/null 2>&1; then
    run "update-desktop-database '$USER_APPS_DIR' || true"
  fi
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    # In case Geany installed icons into ~/.local/share/icons (rare); safe to refresh
    run "gtk-update-icon-cache -q \"$HOME/.local/share/icons/hicolor\" 2>/dev/null || true"
  fi
}

verify_leftovers() {
  echo
  say "${CYAN}Verifying leftovers...${NC}"
  run "command -v geany || true"
  run "which geany || true"
  run "find '$HOME/.local' -maxdepth 3 -iname 'geany*' 2>/dev/null || true"
  run "find '$HOME/.config' -maxdepth 2 -iname 'geany*' 2>/dev/null || true"
  run "test -e '$GLOBAL_SYMLINK' && ls -l '$GLOBAL_SYMLINK' || true"
}

header

# ---- Quick presence check ----
USER_INSTALL_PRESENT=false
[[ -x "$USER_BIN" ]] && USER_INSTALL_PRESENT=true
[[ -d "$USER_LIB_DIR" || -d "$USER_SHARE_DIR" || -d "$USER_INCLUDE_DIR" ]] && USER_INSTALL_PRESENT=true

if ! $USER_INSTALL_PRESENT; then
  say "${YELLOW}No obvious user-local Geany installation detected under ~/.local.${NC}"
  say "We'll still offer to remove config, desktop entries, and a possible global symlink."
fi

echo
say "${CYAN}Planned actions:${NC}"
$USER_INSTALL_PRESENT && say " - Remove user-local files under ~/.local related to Geany"
say " - Remove desktop entries in: $USER_APPS_DIR"
say " - Remove config in: $CONFIG_DIR"
say " - Remove build directories: ${BUILD_GLOBS[*]}"
say " - Remove global symlink (if it points to ~/.local/bin/geany): $GLOBAL_SYMLINK"
say " - Clean PATH edits from ~/.bashrc and ~/.zshrc"
echo

ask_yes_no "Proceed with these actions?" || { say "${YELLOW}Aborted.${NC}"; exit 0; }

echo
say "${CYAN}Step 1: Remove user-local Geany binaries, libs, headers, shares${NC}"
remove_files "$USER_BIN" "$USER_LIB_DIR" "$USER_INCLUDE_DIR" "$USER_SHARE_DIR"

# Also remove pkg-config files that may have been installed (e.g., geany.pc)
if [[ -d "$USER_PKGCONFIG_DIR" ]]; then
  say "${CYAN}Step 1a: Remove pkg-config entries for Geany${NC}"
  remove_matching "$USER_PKGCONFIG_DIR" "geany*.pc"
fi

echo
say "${CYAN}Step 2: Remove desktop entries${NC}"
for df in "${DESKTOP_FILES[@]}"; do
  [[ -f "$df" ]] && say " - Removing $df"
done
remove_files "${DESKTOP_FILES[@]}"
refresh_desktop_cache

echo
say "${CYAN}Step 3: Remove user configuration${NC}"
remove_files "$CONFIG_DIR"

echo
say "${CYAN}Step 4: Remove build directories${NC}"
for glob in "${BUILD_GLOBS[@]}"; do
  [[ -e "$glob" ]] && say " - Removing $glob"
done
remove_files "${BUILD_GLOBS[@]}"

echo
say "${CYAN}Step 5: Remove global symlink if it points to ~/.local/bin/geany${NC}"
if [[ -L "$GLOBAL_SYMLINK" ]]; then
  TARGET="$(readlink -f "$GLOBAL_SYMLINK" || true)"
  if [[ "$TARGET" == "$USER_BIN" ]]; then
    say " - Removing symlink $GLOBAL_SYMLINK -> $TARGET"
    run "sudo rm -f -- '$GLOBAL_SYMLINK'"
  else
    say "${YELLOW} - $GLOBAL_SYMLINK exists but does not point to $USER_BIN (points to: ${TARGET:-unknown}). Leaving it alone.${NC}"
  fi
elif [[ -e "$GLOBAL_SYMLINK" ]]; then
  say "${YELLOW} - $GLOBAL_SYMLINK exists and is not a symlink. Not touching it.${NC}"
else
  say " - No global symlink found."
fi

echo
say "${CYAN}Step 6: Clean PATH edits from shell RC files${NC}"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$rc" ]]; then
    for ln in "${PATH_LINES[@]}"; do
      remove_line_from_shellrc "$ln" "$rc"
    done
  fi
done

echo
say "${CYAN}Step 7: Verification${NC}"
verify_leftovers

echo
if $DRY_RUN; then
  say "${GREEN}Dry run complete. Re-run without --dry-run to apply changes.${NC}"
else
  say "${GREEN}Geany source installation removal complete!${NC}"
  say "${YELLOW}If your shell still finds 'geany', start a new terminal or run: source ~/.bashrc${NC}"
fi

