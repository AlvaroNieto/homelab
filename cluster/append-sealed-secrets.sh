#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Searching for kustomization.yaml files..."

find ./apps -type f -name "kustomization.yaml" | while read -r kustom_file; do
  app_dir="$(dirname "$kustom_file")"
  echo "📁 Processing $kustom_file"

  # Find all sealed-secret YAMLs in the same directory
  mapfile -t sealed_secrets < <(find "$app_dir" -maxdepth 1 -type f -name "sealed-secret-*.yaml" -printf "%f\n")

  if [ ${#sealed_secrets[@]} -eq 0 ]; then
    echo "⚠️  No sealed secrets in $app_dir, skipping..."
    continue
  fi

  # Extract all existing resource entries from kustomization.yaml
  existing_resources=$(yq eval '.resources // [] | .[]' "$kustom_file")

  updated=false

  for sealed_file in "${sealed_secrets[@]}"; do
    if ! grep -qxF "$sealed_file" <<< "$existing_resources"; then
      echo "➕ Appending $sealed_file to $kustom_file"
      yq eval -i ".resources += [\"$sealed_file\"]" "$kustom_file"
      updated=true
    else
      echo "✅ Already included: $sealed_file"
    fi
  done

  if ! $updated; then
    echo "🟡 Nothing changed in $kustom_file"
  else
    echo "✅ Updated $kustom_file"
  fi

done
