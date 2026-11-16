#!/usr/bin/env bash
# Check that referenced ~/nixos/** paths exist in the repo

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

status=0
while IFS=: read -r file line path; do
    # resolve relative to this checkout, not $HOME/nixos:
    if [[ ! -e .${path#'~/nixos'} ]]; then
        echo "$file:$line: $path does not exist" >&2
        status=1
    fi
done < <(
    # shellcheck disable=SC2088 # literal tilde is intended
    rg --hidden --glob '!.git/' \
        --with-filename --line-number --only-matching \
        '~/nixos(/[\w.+@-]+)*'
)

exit "$status"
