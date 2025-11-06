#!/usr/bin/env bash
#==============================================================================:
# Script Name:    gitignore.sh
# Description:    Generate or update a gitignore file
# Author:         david
# Project:        gitignore
# Domain:         davit
# License:        MIT
# Version:        0.0.2
# Status:         development
# Created:        2025-11-03 23:44:32
# Updated:        2025-11-03 23:44:32
# UUID:           67edad03-556a-44ec-adb5-13dab353ea59
# $Id: code-style v0.1.4 2025/11/04 18:00:00
# Style:          code-style v0.1.4
#==============================================================================:
#set -euo pipefail
#------------------------------------------------------------------------------:
# SHELLCHECK DIRECTIVES
#------------------------------------------------------------------------------:
# shellcheck disable=SC2155,SC1091,SC1090
# Notes:
#   These warnings are disabled for structural templates.
#------------------------------------------------------------------------------:

#------------------------------------------------------------------------------:
# GLOBALS
#------------------------------------------------------------------------------:

 SCRIPT_NAME="$(basename "$0")"
 SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
 VERSION="0.0.2"
 UUID="67edad03-556a-44ec-adb5-13dab353ea59"
 LOG_DIR="${LOG_DIR:-${SCRIPT_DIR}/../logs}"
 LOG_FILE="${LOG_FILE:-${LOG_DIR}/${SCRIPT_NAME%.sh}.log}"
readonly  SCRIPT_DIR VERSION LOG_DIR LOG_FILE UUID
mkdir -p "$LOG_DIR"

#------------------------------------------------------------------------------:
# Load .env variables
#------------------------------------------------------------------------------:


#------------------------------------------------------------------------------:
# LOGGER
#------------------------------------------------------------------------------:
if ! source "/opt/davit/bin/davit-logger.sh" 2>/dev/null; then
  echo "[WARN] External logger not found, using fallback."
  log_info() { echo "[INFO] $*"; }
  log_warn() { echo "[WARN] $*"; }
  log_error() { echo "[ERROR] $*"; }
fi

# === CONFIGURATION ===
LIB_DIR="/opt/davit/lib/gitignore"

# === LOGGING HELPERS ===
log_info()  { echo -e "[INFO] $*"; }
log_warn()  { echo -e "[WARN] $*" >&2; }
log_error() { echo -e "[ERROR] $*" >&2; }

#------------------------------------------------------------------------------:
# FUNCTIONS
#------------------------------------------------------------------------------:
usage() {
cat <<USAGE
Usage: $0 [options]

Options:
  -i, --insert [template]   Insert .gitignore template (default: davit)
  -m, --merge [template]    Merge template into existing .gitignore
  -r, --replace [template]  Replace existing .gitignore with template
  -h, --help                Show this help message
  -v, --version             Show version

Examples:
  $0 -i [davit]            # insert default davit.gitignore
  $0 -i node               # insert node.gitignore
  $0 -m python             # merge python.gitignore into existing .gitignore
  $0 -r java               # replace .gitignore with java.gitignore
USAGE
}



# === LOAD TEMPLATE INDEX ====================================================:
build_template_index() {
  local lib="${LIB_DIR}"
  declare -gA TEMPLATE_MAP=()

  while IFS= read -r file; do
    local base="$(basename "$file")"
    local name="${base%.gitignore}"
    local key="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
    TEMPLATE_MAP["$key"]="$name"
  done < <(find "$lib" -type f -name "*.gitignore" 2>/dev/null)
}

resolve_template_name() {
  local query="${1,,}"  # lowercase input
  if [[ -n "${TEMPLATE_MAP[$query]:-}" ]]; then
    echo "${TEMPLATE_MAP[$query]}"
  else
    log_error "Template '$query' not found (case-insensitive search)"
    log_info "Available templates:"
    for key in "${!TEMPLATE_MAP[@]}"; do
      echo "  - ${TEMPLATE_MAP[$key]}.gitignore"
    done
    exit 1
  fi
}


# === CORE FUNCTION ===
get_gitignore_template() {
  local template="${1:-davit}"

  # Build index if not already done
  [[ ${#TEMPLATE_MAP[@]} -eq 0 ]] && build_template_index

  # Resolve to real case-sensitive filename
  local resolved
  resolved="$(resolve_template_name "$template")"
  local src="${LIB_DIR}/${resolved}.gitignore"

  if [[ ! -f "$src" ]]; then
    log_error "Template '${resolved}.gitignore' not found in ${LIB_DIR}"
    exit 1
  fi

  echo "$src"
}

# === ACTION: INSERT ===
insert_gitignore() {
  local template="${1:-davit}"
  local src
  src="$(get_gitignore_template "$template")"

  if [[ -f ".gitignore" ]]; then
    cp ".gitignore" "old.gitignore"
    cp "$src" "davit.gitignore"
    log_info "Existing .gitignore backed up to old.gitignore"
    log_info "Inserted template as davit.gitignore"
  else
    cp "$src" ".gitignore"
    log_info "Created .gitignore from ${template}.gitignore"
  fi
}

# === ACTION: MERGE ===========================================================:
merge_gitignore() {
  local template="${1:-davit}"
  local src
  src="$(get_gitignore_template "$template")"

  if [[ ! -f ".gitignore" ]]; then
    cp "$src" ".gitignore"
    log_info "No .gitignore found, created new one from ${template}.gitignore"
  else
    log_info "Merging ${template}.gitignore into .gitignore"
    cat "$src" >> ".gitignore"
    # Remove duplicates and blank lines
    awk '!seen[$0]++' .gitignore | sed '/^$/N;/^\n$/D' > .gitignore.tmp
    mv .gitignore.tmp .gitignore
    log_info "Merged template and removed duplicates"
  fi
}


# === ACTION: REPLACE =========================================================:
replace_gitignore() {
  local template="${1:-davit}"
  local src
  src="$(get_gitignore_template "$template")"

  if [[ -f ".gitignore" ]]; then
    cp ".gitignore" "old.gitignore"
    log_info "Backed up existing .gitignore to old.gitignore"
  fi

  cp "$src" ".gitignore"
  log_info "Replaced .gitignore with ${template}.gitignore"
}


# === ARG PARSER ==============================================================:
parse_args() {
  if [[ $# -eq 0 ]]; then
    usage; exit 1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -i|--insert)
        shift
        insert_gitignore "${1:-davit}"
        exit 0
        ;;
      -m|--merge)
        shift
        merge_gitignore "${1:-davit}"
        exit 0
        ;;
      -r|--replace)
        shift
        replace_gitignore "${1:-davit}"
        exit 0
        ;;
      -h|--help)
        usage; exit 0
        ;;
      -v|--version)
        echo "$VERSION"; exit 0
        ;;
      *)
        log_warn "Unknown option: $1"
        usage; exit 1
        ;;
    esac
  done
}

#------------------------------------------------------------------------------:
# MAIN
#------------------------------------------------------------------------------:
main() {
  log_header "=== Starting ${SCRIPT_NAME} ==="
  log_info "Executing script logic..."
  parse_args "$@"
  log_success "Execution complete."
}
# === ENTRY POINT =============================================================:
main "$@"


#==============================================================================:
# FOOTER / TODO
#------------------------------------------------------------------------------:
#  fix, feat or request---------------------¬
#  [I]ssue, [T]ask or [F]unc number---¬     |     
#  section or line number-------¬     |     |
#  script---¬            |      |     |     |
#           ↓            ↓      ↓     ↓     ↓
# TOD0(gitignore):[main]|[130]:[T001]: Implement business logic.
# F1XME(gitignore):[parse_args]|[115]:[F001]: Extend option parsing.
# NOTES: Created using DAVIT create_script.sh v0.1.0
#------------------------------------------------------------------------------:
# TODO(gitignore):[GLOBALS]:[T001]: if ".env" and or requirements exist load /
#                                     only if necessary 
# TODO(gitignore):[GLOBALS]:[T002]: readonly variables causing an issue
# TODO(gitignore):[GLOBALS]:[T003]: Add shellcheck disables or config "."
# TODO(create_script):[SHELLCHK]:[T004]: Add shellcheck section
# TODO(create_script):[SHELLCHK]:[T005]: fix: readonly variables issues 
# TODO(gitignore):[GLOBALS]:[T006]: VERSION should be read from script header
#==============================================================================:
