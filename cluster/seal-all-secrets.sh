#!/bin/bash

# Script options:
# -e: Exit immediately if any command fails.
# -u: Treat unset variables as an error and exit.
# -o pipefail: The exit status of a pipeline is the status of the last command that exited with a non-zero status, or zero if all succeed.
set -euo pipefail

# Base path to look for secret.yaml files (e.g., cluster/apps)
BASE_PATH=./apps/

# Path to the public certificate used by kubeseal
SEALED_CERT_PATH=./.sealed-secrets/pub-cert.pem

# Check if the public certificate exists
if [ ! -f "$SEALED_CERT_PATH" ]; then
  echo "❌ Public certificate not found at $SEALED_CERT_PATH"
  exit 1
fi

# Find all secret.yaml files under the base path
find "$BASE_PATH" -type f -name "secret.yaml" | while read -r secret_file; do
  echo "🔍 Processing $secret_file"

  # Get the directory containing the secret.yaml
  dir=$(dirname "$secret_file")

  # Count the number of YAML documents in the file
  # `yq eval-all 'length'` gives the count per document; `wc -l` counts how many lines → number of documents
  doc_count=$(yq eval-all 'length' "$secret_file" | wc -l)

  # Skip files with no documents
  if [ "$doc_count" -eq 0 ]; then
    echo "⚠️ No documents found in $secret_file, skipping..."
    continue
  fi

  # Iterate over each YAML document by index
  for i in $(seq 0 $((doc_count - 1))); do
    # Extract the current document by index
    doc_content=$(yq eval-all "select(document_index == $i)" "$secret_file")

    # Create a temporary file for this individual document
    temp_doc_file=$(mktemp "$dir/temp-secret-XXXX.yaml")

    # Write the document content into the temporary file
    echo "$doc_content" > "$temp_doc_file"

    # Extract kind, namespace, and name from the YAML
    kind=$(yq e '.kind' "$temp_doc_file" | head -n 1)
    namespace=$(yq e '.metadata.namespace' "$temp_doc_file" | head -n 1)
    name=$(yq e '.metadata.name' "$temp_doc_file" | head -n 1)

    # Ensure the document is a Kubernetes Secret
    if [ "$kind" != "Secret" ]; then
      echo "⚠️ Document $temp_doc_file is not a 'Secret' (it's '$kind'), skipping..."
      rm "$temp_doc_file"
      continue
    fi

    # Ensure namespace is defined
    if [ -z "$namespace" ] || [ "$namespace" == "null" ]; then
      echo "❌ Missing namespace in $temp_doc_file, skipping..."
      rm "$temp_doc_file"
      continue
    fi

    # Ensure secret name is defined
    if [ -z "$name" ] || [ "$name" == "null" ]; then
      echo "❌ Missing name in $temp_doc_file, skipping..."
      rm "$temp_doc_file"
      continue
    fi

    # Define the output path for the sealed secret
    sealed_file="$dir/sealed-secret-$name.yaml"
    echo "  - Sealing secret $name in namespace $namespace → $sealed_file"

    # Seal the secret using kubeseal
    kubeseal --cert "$SEALED_CERT_PATH" \
      --format yaml \
      --namespace "$namespace" \
      < "$temp_doc_file" \
      | yq eval '(.spec.encryptedData // {}) |= with_entries(.value |= "\(.)\n" | .style = "folded")' -o=y > "$sealed_file"

    # Clean up the temporary file
    rm "$temp_doc_file"
  done
done

echo "✅ All plaintext secrets have been sealed (but still exist locally)."
echo "Commit ONLY the sealed-secret-*.yaml files, never the original secret.yaml files."

# Call the script to append sealed secrets to kustomization.yaml files
# echo "📦 Adding sealed-secret files to kustomization.yaml manifests..."
# bash "$(dirname "$0")/append-sealed-secrets.sh"
