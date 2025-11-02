#!/bin/bash

set -eo pipefail

# Configuration
GIT_URL="git@github.com:JS-CodeGamer/.dotfiles.git"
DOTFILES_DIR="${HOME}/.config/dotfiles"
STOWPKGS_FILE=".stowpkgs"

# Error tracking
declare -A FAILED_FILES
FAILED_PACKAGES=()

# Parse arguments
CUSTOM_STOWPKG=""
while getopts ":s:h" opt; do
  case $opt in
    s) CUSTOM_STOWPKG="$OPTARG" ;;
    h)
      echo "Usage: $0 [-s stowpkg_file]"
      echo "  -s: Specify custom .stowpkgs file"
      exit 0
      ;;
    \?)
      echo "Error: Invalid option -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Clone repository if needed
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone "$GIT_URL" --depth 1 --single-branch "$DOTFILES_DIR"
else
  echo "Dotfiles directory already exists at $DOTFILES_DIR"
fi

# Determine stowpkgs file
STOWPKG_PATH="${CUSTOM_STOWPKG:-${DOTFILES_DIR}/${STOWPKGS_FILE}}"

if [ ! -f "$STOWPKG_PATH" ]; then
  echo "Error: Stowpkgs file not found at $STOWPKG_PATH" >&2
  exit 1
fi

# Base stow command
STOW_BASE="stow -t $HOME -d $DOTFILES_DIR --dotfiles -Rv"

# Function to process stow output
process_package() {
  local pkg="$1"
  local output
  local exit_code
  
  output=$($STOW_BASE "$@" 2>&1) || exit_code=$?
  
  if [ ${exit_code:-0} -ne 0 ]; then
    FAILED_PACKAGES+=("$pkg")
    # Extract file paths from error messages
    while IFS= read -r line; do
      if [[ "$line" =~ (WARNING|ERROR|conflict) ]]; then
        FAILED_FILES["$pkg"]+="$line"$'\n'
      fi
    done <<< "$output"
  fi
}

echo "Installing dotfiles packages..."

# Process packages without --no-folding
echo "Installing standard packages..."
while IFS= read -r pkg; do
  [ -z "$pkg" ] || [[ "$pkg" =~ ^# ]] && continue
  process_package "$pkg" "$pkg"
done < <(grep -v '^:' "$STOWPKG_PATH")

# Process packages with --no-folding
echo "Installing no-folding packages..."
while IFS= read -r line; do
  pkg=$(echo "$line" | cut -d: -f2-)
  process_package "$pkg (no-folding)" --no-folding "$pkg"
done < <(grep '^:' "$STOWPKG_PATH")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Report results
if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
  echo "✓ All packages installed successfully!"
else
  echo "✗ Failed packages (${#FAILED_PACKAGES[@]}):"
  for pkg in "${FAILED_PACKAGES[@]}"; do
    echo ""
    echo "  Package: $pkg"
    if [ -n "${FAILED_FILES[$pkg]}" ]; then
      echo "${FAILED_FILES[$pkg]}" | sed 's/^/    /'
    fi
  done
  exit 1
fi
