#!/usr/bin/env bash
#==============================================================================
# Script: manifest_generate.sh
# Description: Generates readable manifest.json for gitignore templates.
# Author: David / DavitTec
# Version: 0.1.0
# Strict template verification enforced
#==============================================================================
#------------------------------------------------------------------------------:
# SHELLCHECK DIRECTIVES
#------------------------------------------------------------------------------:
# shellcheck disable=SC2155,SC1091,SC1090,SC2016
# Notes:
#   These warnings are disabled for structural templates.
#------------------------------------------------------------------------------:
#set -euo pipefail

#------------------------------------------------------------------------------
# Load .env
#------------------------------------------------------------------------------
if [[ -f ".env" ]]; then
  source ".env"
fi
VERSION=${VERSION:-0.1.0}
SRC_DIR="./lib/gitignore"
DEV_MANIFEST="./manifest.json"
INSTALL_MANIFEST="/opt/davit/etc/manifest.json"

#------------------------------------------------------------------------------:
# Logging (fallback if davit-logger not present)
#------------------------------------------------------------------------------:
if ! source "/opt/davit/bin/davit-logger.sh" &>/dev/null; then
  log_info()  { printf "[INFO] %s\n" "$*"; }
  log_warn()  { printf "[WARN] %s\n" "$*" >&2; }
  log_error() { printf "[ERROR] %s\n" "$*" >&2; }
  log_success(){ printf "[OK] %s\n" "$*"; }
fi

#------------------------------------------------------------------------------
# Function: compute SHA256
#------------------------------------------------------------------------------
compute_sha() {
  local file="$1"
  sha256sum "$file" | awk '{print $1}'
}

#------------------------------------------------------------------------------
# Generate manifest structure
#------------------------------------------------------------------------------
manifest=$(mktemp)

echo "{" > "$manifest"
echo "  \"name\": \"davit-gitignore\"," >> "$manifest"
echo "  \"version\": \"$VERSION\"," >> "$manifest"
echo "  \"_comment_version\": \"Sourced from .env. Do not edit manually.\"," >> "$manifest"
echo "  \"templates_dir\": \"/opt/davit/lib/gitignore\"," >> "$manifest"
echo "  \"_comment_templates\": \"Managed template library. Keys are lowercase lookup names.\"," >> "$manifest"
echo "  \"templates\": {" >> "$manifest"

first_template=true
for category in "$SRC_DIR"/*; do
  if [[ -d "$category" ]]; then
    cat_name=$(basename "$category")
    for template in "$category"/*.gitignore; do
      [[ -f "$template" ]] || continue
      template_name=$(basename "$template" .gitignore)
      key=$(echo "$template_name" | tr '[:upper:]' '[:lower:]')
      sha=$(compute_sha "$template")

      [[ "$first_template" = true ]] || echo "," >> "$manifest"
      first_template=false

      echo "    \"$key\": {" >> "$manifest"
      echo "      \"file\": \"$template_name.gitignore\"," >> "$manifest"
      echo "      \"category\": \"$cat_name\"," >> "$manifest"
      echo "      \"sha256\": \"$sha\"," >> "$manifest"
      echo "      \"_comment\": \"Checksum verifies integrity. Do not modify manually.\"" >> "$manifest"
      echo "    }" >> "$manifest"
    done
  fi

done

echo "  }" >> "$manifest"
echo "}" >> "$manifest"

#------------------------------------------------------------------------------
# Save dev manifest
#------------------------------------------------------------------------------
cp "$manifest" "$DEV_MANIFEST"
log_info "Dev manifest generated at $DEV_MANIFEST"

#------------------------------------------------------------------------------
# Save install manifest
#------------------------------------------------------------------------------
mkdir -p "$(dirname "$INSTALL_MANIFEST")"
cp "$manifest" "$INSTALL_MANIFEST"
log_info "Install manifest generated at $INSTALL_MANIFEST"

rm -f "$manifest"
