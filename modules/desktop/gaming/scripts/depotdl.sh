#!/usr/bin/env bash

# Original script by: https://github.com/ThatOverPowered
# See: 78dbd30e

set -euo pipefail
IFS=$'\n\t'

readonly XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly DATA_ROOT="$XDG_DATA_HOME/steam-manifests"
readonly STEAM_LIBRARY_FOLDERS_FILE="$XDG_DATA_HOME/Steam/config/libraryfolders.vdf"

if [[ -t 1 ]]; then
    readonly GREEN=$'\033[32m'
    readonly RED=$'\033[31m'
    readonly YELLOW=$'\033[33m'
    readonly BOLD=$'\033[1m'
    readonly RESET=$'\033[0m'
else
    readonly GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

if [[ -t 2 ]]; then
    readonly ERR_RED=$'\033[31m' ERR_RESET=$'\033[0m'
else
    readonly ERR_RED='' ERR_RESET=''
fi

export FZF_DEFAULT_OPTS+=" --bind 'esc:ignore'"

readonly FZF_NO_INPUT_OPTS=(
    --no-input
    --bind 'j:down,k:up,g:first,G:last'
)
readonly FZF_NO_INPUT_HEADER="j/Down/k/Up - move"

readonly FZF_MULTI_OPTS=(
    --multi
    --bind 'space:toggle+down'
)
readonly FZF_MULTI_HEADER="Space - toggle | Enter - confirm"

die() {
    echo "${ERR_RED}Error: $*${ERR_RESET}" >&2
    exit 1
}

warn() {
    echo "${YELLOW}$*${RESET}"
}

join_lines() {
    local IFS=$'\n'
    printf '%s' "$*"
}

trim() {
    sed -E 's/^[[:space:]]+|[[:space:]]+$//g' <<< "$1"
}

confirm_or_exit() {
    local confirm
    echo
    read -r -p "Proceed? [Y/n]: " confirm || confirm=n
    if [[ ${confirm,,} =~ ^no?$ ]]; then
        echo "Exiting..."
        exit 0
    fi
}

search_steam() {
    sleep 0.1
    curl -fsG "https://store.steampowered.com/api/storesearch" \
        --data-urlencode "term=$1" \
        --data cc=us --data l=en \
        | jq -r '.items[]? | "\( .id )\t\( .name )"'
}
export -f search_steam

pick_steam_app() {
    local selection

    selection=$(
        fzf --disabled \
            --prompt='Steam search: ' \
            --delimiter=$'\t' \
            --with-nth=2 \
            --bind "change:reload:$BASH -c 'search_steam {q}'" \
            < /dev/null
    ) || die "Game selection was dropped."

    IFS=$'\t' read -r MAIN_APP_ID APP_NAME <<< "$selection"
}

fetch_manifest_files() {
    local token

    DEPOT_DIR="$DATA_ROOT/$MAIN_APP_ID"
    DEPOT_LUA_FILE="$DEPOT_DIR/$MAIN_APP_ID.lua"

    if [[ -f "$DEPOT_LUA_FILE" ]]; then
        warn "Using existing manifests in $DEPOT_DIR, skipping fetch..."
        return
    fi

    token=$(rbw get HubcapDB) || die "Could not read HubcapDB token from rbw."

    mkdir -p "$DEPOT_DIR"
    warn "Fetching manifests..."
    if ! printf 'Authorization: Bearer %s\n' "$token" \
        | curl -fsSL -H @- "https://hubcapmanifest.com/api/v1/manifest/$MAIN_APP_ID" \
        | bsdtar -xf - -C "$DEPOT_DIR"; then
        rm -rf "$DEPOT_DIR"
        die "Failed to download or extract manifests for $MAIN_APP_ID."
    fi

    [[ -f "$DEPOT_LUA_FILE" ]] || die "No .lua file found in '$DEPOT_DIR'."
}

fetch_app_info() {
    local game_info

    game_info=$(
        curl -fsSL "https://api.steamcmd.net/v1/info/$MAIN_APP_ID" \
            | jq --compact-output \
                --arg app_id "$MAIN_APP_ID" \
                '.data[$app_id]'
    )

    APP_INSTALL_DIRNAME=$(jq -r '.config.installdir // empty' <<< "$game_info")
    if [[ -z "$APP_INSTALL_DIRNAME" ]]; then
        APP_INSTALL_DIRNAME="$APP_NAME"
    fi
    APP_INSTALL_DIRNAME="${APP_INSTALL_DIRNAME//[\/:*?\"<>|]/}"

    APP_DEPOTS_INFO_JSON=$(jq --compact-output '.depots // {}' <<< "$game_info")
}

find_manifest_files() {
    readarray -d '' -t MANIFEST_FILES < <(
        find "$DEPOT_DIR" -maxdepth 1 -type f -name '*.manifest' -print0
    )
    ((${#MANIFEST_FILES[@]} > 0)) || die "No .manifest files found."
}

declare -a DEPOT_IDS=()
declare -A DEPOT_KEYS=()
declare -A DEPOT_DESCS=()
declare -A DEPOT_MANIFESTS=()

parse_lua() {
    local line id key desc manifest
    local re_key='addappid\(([0-9]+),[[:space:]]*[0-9]+,[[:space:]]*"([^"]+)"\)'
    local re_manifest='setManifestid\(([0-9]+),[[:space:]]*"([^"]+)"'
    local re_desc='--[[:space:]]*(.*)$'

    DEPOT_IDS=()
    DEPOT_KEYS=()
    DEPOT_DESCS=()
    DEPOT_MANIFESTS=()

    while IFS= read -r line; do
        if [[ $line =~ $re_key ]]; then
            id="${BASH_REMATCH[1]}"
            key="${BASH_REMATCH[2]}"
            desc=""
            if [[ $line =~ $re_desc ]]; then
                desc="${BASH_REMATCH[1]}"
            fi
            DEPOT_KEYS["$id"]="$key"
            DEPOT_DESCS["$id"]="$desc"
            continue
        fi

        if [[ $line =~ $re_manifest ]]; then
            id="${BASH_REMATCH[1]}"
            manifest="${BASH_REMATCH[2]}"
            if [[ -n "${DEPOT_KEYS[$id]:-}" && -z "${DEPOT_MANIFESTS[$id]:-}" ]]; then
                DEPOT_MANIFESTS["$id"]="$manifest"
                DEPOT_IDS+=("$id")
            fi
        fi
    done < "$DEPOT_LUA_FILE"

    ((${#DEPOT_IDS[@]} > 0)) || die "No depots with manifest and key found in the .lua file."

    if [[ -n "${DEPOT_MANIFESTS[$MAIN_APP_ID]:-}" ]]; then
        MAIN_DEPOT_ID="$MAIN_APP_ID"
    else
        MAIN_DEPOT_ID="${DEPOT_IDS[0]}"
    fi
}

depot_display_name() {
    local id="$1" desc
    local re_suffix='^(.*)[[:space:]]+-[[:space:]]+Depot'
    local re_prefix='^Depot[[:space:]]+[0-9]+[[:space:]]*--?[[:space:]]*(.*)$'
    local re_bare='^Depot[[:space:]]+[0-9]+$'

    if [[ "$MAIN_DEPOT_ID" == "$id" ]]; then
        echo "$APP_NAME"
        return
    fi

    desc=$(trim "${DEPOT_DESCS[$id]:-}")

    if [[ $desc =~ $re_suffix ]]; then
        trim "${BASH_REMATCH[1]}"
    elif [[ $desc =~ $re_prefix ]]; then
        trim "${BASH_REMATCH[1]}"
    elif [[ -z "$desc" || $desc =~ $re_bare ]]; then
        printf '%s - Depot %s' "$APP_NAME" "$id"
    else
        printf '%s - %s' "$APP_NAME" "$desc"
    fi
}

declare -A DEPOT_NAMES=()

compute_depot_names() {
    local id

    DEPOT_NAMES=()
    for id in "${DEPOT_IDS[@]}"; do
        DEPOT_NAMES["$id"]="$(depot_display_name "$id")"
    done
}

verify_manifests_present() {
    local id expected missing=0

    for id in "${DEPOT_IDS[@]}"; do
        expected="$DEPOT_DIR/${id}_${DEPOT_MANIFESTS[$id]}.manifest"
        if [[ ! -f "$expected" ]]; then
            echo "${ERR_RED}  MISSING: $(basename "$expected")${RESET}" >&2
            missing=1
        fi
    done

    ((missing == 0)) || die "Missing .manifest files."
}

prepare_keys_file() {
    local id

    DEPOT_KEYS_FILE="$DEPOT_DIR/${MAIN_APP_ID}.keys"
    for id in "${DEPOT_IDS[@]}"; do
        printf '%s;%s\n' "$id" "${DEPOT_KEYS[$id]}"
    done > "$DEPOT_KEYS_FILE"
}

print_summary() {
    local id max_len=0 len

    echo "${BOLD}${APP_NAME} ( ${MAIN_APP_ID} )${RESET}"
    echo
    echo "${BOLD}Lua:${RESET}         $(basename "$DEPOT_LUA_FILE")"
    echo "${BOLD}Manifests:${RESET}   ${#MANIFEST_FILES[@]}"
    echo "${BOLD}Depots:${RESET}      ${#DEPOT_IDS[@]}"

    for id in "${DEPOT_IDS[@]}"; do
        len="${#DEPOT_NAMES[$id]}"
        if ((len > max_len)); then
            max_len=$len
        fi
    done

    echo
    for id in "${DEPOT_IDS[@]}"; do
        printf '%s[ ]%s %-*s | %-7s - %s\n' \
            "$YELLOW" "$RESET" \
            "$max_len" "${DEPOT_NAMES[$id]}" \
            "$id" "${DEPOT_MANIFESTS[$id]}"
    done
}

declare -gA SELECTED_DEPOTS=()

prompt_depot_selection() {
    local id selection
    local -a rows picked

    for id in "${DEPOT_IDS[@]}"; do
        rows+=("$(printf "%s\t%s" "$id" "${DEPOT_NAMES[$id]} ( $id )")")
    done

    selection=$(
        printf '%s\n' "${rows[@]}" \
            | fzf "${FZF_NO_INPUT_OPTS[@]}" "${FZF_MULTI_OPTS[@]}" \
                --delimiter=$'\t' --with-nth=2 --accept-nth=1 \
                --header="$(
                    join_lines \
                        'Select depots to download.' \
                        "$FZF_NO_INPUT_HEADER | $FZF_MULTI_HEADER"
                )"
    ) || die "Depot selection was dropped."

    readarray -t picked <<< "$selection"

    SELECTED_DEPOTS=()
    for id in "${picked[@]}"; do
        SELECTED_DEPOTS["$id"]=1
    done
}

prompt_library_selection() {
    local all_library_dirs library_dir

    all_library_dirs=$(grep -oP '"path"\s+"\K[^"]+' "$STEAM_LIBRARY_FOLDERS_FILE") \
        || die "Could not read Steam library folders from $STEAM_LIBRARY_FOLDERS_FILE"

    library_dir=$(
        fzf "${FZF_NO_INPUT_OPTS[@]}" \
            --header="$(join_lines 'Select library for game installation.' "$FZF_NO_INPUT_HEADER")" \
            --preview 'ls {}/steamapps/common' \
            <<< "$all_library_dirs"
    ) || die "Library selection was dropped."

    APP_INSTALL_DIR="$library_dir/steamapps/common/$APP_INSTALL_DIRNAME"
}

depot_info() {
    local id="$1" key="$2" value

    value=$(
        jq -r \
            --exit-status \
            --arg id "$id" \
            --arg key "$key" \
            '.[$id].manifests.public[$key]' \
            <<< "$APP_DEPOTS_INFO_JSON"
    ) || return 1

    numfmt --to=iec --suffix=B --format='%.1f' "$value"
}

print_selection_and_collect() {
    local id download_size on_disk_size
    DEPOTS_TO_DOWNLOAD=()

    echo
    echo "${BOLD}Install to${RESET}: ${YELLOW}$APP_INSTALL_DIR${RESET}"
    echo
    for id in "${DEPOT_IDS[@]}"; do
        if [[ "${SELECTED_DEPOTS[$id]:-}" == 1 ]]; then
            echo "${GREEN}[+]${RESET} ${DEPOT_NAMES[$id]} ( $id )"
            if download_size=$(depot_info "$id" download) \
                && on_disk_size=$(depot_info "$id" size); then
                printf "    %s, %s\n" \
                    "${BOLD}Download size${RESET}: ${YELLOW}${download_size}${RESET}" \
                    "${BOLD}on disk${RESET}: ${YELLOW}${on_disk_size}${RESET}"
            fi
            DEPOTS_TO_DOWNLOAD+=("$id")
        else
            echo "${RED}[-]${RESET} ${DEPOT_NAMES[$id]} ( $id )"
        fi
    done

    ((${#DEPOTS_TO_DOWNLOAD[@]} > 0)) || die "No depots selected for download."
}

run_downloader() {
    local id

    echo
    for id in "${DEPOTS_TO_DOWNLOAD[@]}"; do
        warn "Downloading depot ${id}..."

        echo
        DepotDownloaderMod \
            -app "$MAIN_APP_ID" \
            -depot "$id" \
            -manifest "${DEPOT_MANIFESTS[$id]}" \
            -manifestfile "$DEPOT_DIR/${id}_${DEPOT_MANIFESTS[$id]}.manifest" \
            -depotkeys "$DEPOT_KEYS_FILE" \
            -dir "$APP_INSTALL_DIR" \
            -validate
        echo "Depot ${id} completed."
        echo
    done
    echo "Process finished."

    echo
    echo "${BOLD}Installed to${RESET}: ${YELLOW}$APP_INSTALL_DIR${RESET}"
    echo
    for id in "${DEPOTS_TO_DOWNLOAD[@]}"; do
        echo "${GREEN}[+]${RESET} ${DEPOT_NAMES[$id]} ( ${YELLOW}$id${RESET} )"
    done
    echo
}

main() {
    rbw unlock

    pick_steam_app

    fetch_manifest_files
    find_manifest_files

    parse_lua
    verify_manifests_present
    prepare_keys_file
    compute_depot_names

    print_summary
    confirm_or_exit
    prompt_depot_selection
    fetch_app_info
    prompt_library_selection
    print_selection_and_collect

    confirm_or_exit
    run_downloader
}

main "$@"
