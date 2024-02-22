#!/usr/bin/env sh
    tag=$1

    tag=$(echo $tag | sed "s/@.*//g") # Strip everything after '@' (e.g., "v1.2.3@sha256:abc123" -> "v1.2.3")

    # Remove 'version-' prefix if it exists (e.g., "version-a78f38c1" -> "a78f38c1")
    tag=$(echo "$tag" | sed -E 's/^version-//')

    # Handling dates in year-month and year-month-day format (e.g., "2023-11-15" -> "2023.11.15", "2022-04" -> "2022.04")
    if echo "$tag" | grep -qE '^[0-9]{4}-[0-9]{2}(-[0-9]{2})?$'; then
        tag=$(echo "$tag" | tr '-' '.')
    fi

    # Handle specific prefix like 'x64-' followed by a numeric version (e.g., "x64-1.2.3" -> "1.2.3")
    if echo "$tag" | grep -qE '^[a-zA-Z0-9]+-[0-9]+\.[0-9]+'; then
        tag=$(echo "$tag" | sed -E 's/^[a-zA-Z0-9]+-//')
    fi

    # Handle complex tags with prefixes and multiple version parts (e.g., "abc123-v1.2.3" -> "1.2.3")
    if echo "$tag" | grep -qE '^[a-zA-Z0-9]+-v[0-9]+\.[0-9]+\.[0-9]+'; then
        tag=$(echo "$tag" | sed -E 's/^[a-zA-Z0-9]+-v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    fi

    # Handling dates in RELEASE tags (e.g., "RELEASE.2023-11-20T22-40-07Z" -> "2023.11.20")
    if echo "$tag" | grep -qE 'RELEASE\.[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
        tag=$(echo "$tag" | cut -d'.' -f2 | cut -dT -f1 | tr '-' '.')
    fi

    # Standard version number extraction (e.g., "version-1.2.3" -> "1.2.3")
    if echo "$tag" | grep -qE '[0-9]+\.[0-9]+'; then
        tag=$(echo "$tag" | sed -E 's/[^0-9.]*([0-9]+(\.[0-9]+)*).*/\1/')
    fi

    # Always remove the leading 'v' or 'V' and any non-letter or non-number characters immediately following it (e.g., "v1.2.3" -> "1.2.3")
    tag=$(echo "$tag" | sed -E 's/^[vV]//; s/^[^a-zA-Z0-9]+//')

    echo "$tag"
