#!/usr/bin/env bash

# Script by: https://github.com/ThatOverPowered

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DATA_ROOT="$SCRIPT_DIR/Data"
readonly DOWNLOADER_BIN="$SCRIPT_DIR/DepotDownloaderMod"

if [[ -t 1 ]]; then
    readonly COLOR_GREEN=$'\033[32m'
    readonly COLOR_RED=$'\033[31m'
    readonly COLOR_BOLD=$'\033[1m'
    readonly COLOR_RESET=$'\033[0m'
else
    readonly COLOR_GREEN='' COLOR_RED='' COLOR_BOLD='' COLOR_RESET=''
fi

die() {
    echo "${COLOR_RED}Error: $*${COLOR_RESET}" >&2
    exit 1
}

usage() {
    cat << EOF
Usage: $(basename "$0") [-p directory] <directory>

Processes a directory with .lua and .manifest files to download Steam depots.

Options:
  -p DIR   Path to the working directory (alternative to positional argument)
  -h       Show this help

Example:
  $(basename "$0") /path/to/game
EOF
}

to_absolute_path() {
    local path="$1"
    [[ "$path" = /* ]] && {
        echo "$path"
        return
    }
    echo "$(pwd)/$path"
}

parse_args() {
    local path=""

    while getopts ":p:h" opt; do
        case "$opt" in
            p) path="$OPTARG" ;;
            h)
                usage
                exit 0
                ;;
            :) die "Option -$OPTARG requires an argument." ;;
            \?) die "Unknown option: -$OPTARG" ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ -z "$path" ]]; then
        path="$1"
        shift
    fi

    TARGET_PATH="$(to_absolute_path "$path")"
    [[ -d "$TARGET_PATH" ]] || die "Directory '$TARGET_PATH' does not exist."
}

find_lua_file() {
    local dir="$1" lua
    lua="$(find "$dir" -maxdepth 1 -type f -name '*.lua' -print -quit)"
    [[ -n "$lua" ]] || die "No .lua file found in '$dir'."
    echo "$lua"
}

find_manifest_files() {
    local dir="$1"
    find "$dir" -maxdepth 1 -type f -name '*.manifest'
}

extract_main_app_id() {
    local lua_file="$1"
    grep -m1 -oE 'addappid\([0-9]+' "$lua_file" | grep -oE '[0-9]+' \
        || die "Could not extract AppID from '$lua_file'."
}

extract_app_name() {
    local lua_file="$1" default_id="$2" name

    name="$(grep -E '^-- [A-Za-z]' "$lua_file" \
        | grep -v -E 'Lua|Manifest|Created|Website|Total|Shared|DLCS|Depots' \
        | head -n1 \
        | sed -E 's/^-- *//')"

    echo "${name:-App $default_id}"
}

declare -a DEPOT_IDS=()
declare -A DEPOT_KEY=()
declare -A DEPOT_DESC=()
declare -A DEPOT_MANIFEST=()

parse_lua() {
    local lua_file="$1" line id key desc manifest

    DEPOT_IDS=()
    DEPOT_KEY=()
    DEPOT_DESC=()
    DEPOT_MANIFEST=()

    while IFS= read -r line; do
        if [[ "$line" =~ addappid\(([0-9]+),[[:space:]]*[0-9]+,[[:space:]]*\"([^\"]+)\"\) ]]; then
            id="${BASH_REMATCH[1]}"
            key="${BASH_REMATCH[2]}"
            desc=""
            [[ "$line" =~ --[[:space:]]*(.*)$ ]] && desc="${BASH_REMATCH[1]}"
            DEPOT_KEY["$id"]="$key"
            DEPOT_DESC["$id"]="$desc"
            continue
        fi

        if [[ "$line" =~ setManifestid\(([0-9]+),[[:space:]]*\"([^\"]+)\" ]]; then
            id="${BASH_REMATCH[1]}"
            manifest="${BASH_REMATCH[2]}"
            if [[ -n "${DEPOT_KEY[$id]:-}" ]]; then
                DEPOT_MANIFEST["$id"]="$manifest"
                DEPOT_IDS+=("$id")
            fi
        fi
    done < "$lua_file"

    [[ ${#DEPOT_IDS[@]} -gt 0 ]] \
        || die "No depots with manifest and key found in the .lua file."
}

depot_display_name() {
    local id="$1" desc

    if [[ "${DEPOT_IDS[0]}" == "$id" ]]; then
        echo "$APP_NAME"
        return
    fi

    desc="$(echo "${DEPOT_DESC[$id]:-}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"

    if [[ "$desc" =~ ^(.*)[[:space:]]+-[[:space:]]+Depot ]]; then
        echo "${BASH_REMATCH[1]}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
    elif [[ "$desc" =~ ^Depot[[:space:]]+[0-9]+[[:space:]]*--?[[:space:]]*(.*)$ ]]; then
        echo "${BASH_REMATCH[1]}" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g'
    elif [[ -z "$desc" || "$desc" =~ ^Depot[[:space:]]+[0-9]+$ ]]; then
        echo "$APP_NAME - Depot $id"
    else
        echo "$APP_NAME - $desc"
    fi
}

verify_manifests_present() {
    local dir="$1" id expected missing=0

    for id in "${DEPOT_IDS[@]}"; do
        expected="$dir/${id}_${DEPOT_MANIFEST[$id]}.manifest"
        if [[ ! -f "$expected" ]]; then
            echo "${COLOR_RED}  MISSING: $(basename "$expected")${COLOR_RESET}" >&2
            missing=1
        fi
    done

    [[ $missing -eq 0 ]] || die "Missing .manifest files."
}

prepare_data_dir() {
    local source_dir="$1" folder_name data_dir manifest auth_file id

    folder_name="$(basename "$source_dir")"
    data_dir="$DATA_ROOT/$folder_name"
    mkdir -p "$data_dir"

    for manifest in "${MANIFEST_FILES[@]}"; do
        cp "$manifest" "$data_dir/"
    done

    auth_file="$data_dir/${MAIN_APP_ID}.keys"
    : > "$auth_file"
    for id in "${DEPOT_IDS[@]}"; do
        echo "${id};${DEPOT_KEY[$id]}" >> "$auth_file"
    done

    DATA_DIR="$data_dir"
}

print_summary() {
    local id name max_len=0 len

    echo "${COLOR_BOLD}${APP_NAME} ( ${MAIN_APP_ID} )${COLOR_RESET}"
    echo
    echo "${COLOR_BOLD}Lua:${COLOR_RESET}         $(basename "$LUA_FILE")"
    echo "${COLOR_BOLD}Manifests:${COLOR_RESET}   ${#MANIFEST_FILES[@]}"
    echo "${COLOR_BOLD}Depots:${COLOR_RESET}      ${#DEPOT_IDS[@]}"

    declare -gA DEPOT_NAME=()
    for id in "${DEPOT_IDS[@]}"; do
        name="$(depot_display_name "$id")"
        DEPOT_NAME["$id"]="$name"
        len="${#name}"
        ((len > max_len)) && max_len=$len
    done
    ((max_len == 0)) && max_len=1

    echo
    for id in "${DEPOT_IDS[@]}"; do
        printf -- "- %-*s | %s - %s\n" "$max_len" "${DEPOT_NAME[$id]}" "$id" "${DEPOT_MANIFEST[$id]}"
    done
}

prompt_depot_selection() {
    local id answer

    declare -gA SELECTED=()
    echo
    for id in "${DEPOT_IDS[@]}"; do
        read -r -p "Download '${DEPOT_NAME[$id]}' ( ${MAIN_APP_ID} )? [y/N]: " answer
        [[ "$answer" =~ ^[Yy]$ ]] && SELECTED["$id"]="yes" || SELECTED["$id"]="no"
    done
}

print_selection_and_collect() {
    local id
    TO_DOWNLOAD=()

    echo
    for id in "${DEPOT_IDS[@]}"; do
        if [[ "${SELECTED[$id]}" == "yes" ]]; then
            echo "  ${COLOR_GREEN}[+]${COLOR_RESET} ${DEPOT_NAME[$id]} ( ${MAIN_APP_ID} )"
            TO_DOWNLOAD+=("$id")
        else
            echo "  ${COLOR_RED}[-]${COLOR_RESET} ${DEPOT_NAME[$id]} ( ${MAIN_APP_ID} )"
        fi
    done
}

confirm_or_exit() {
    local confirm
    echo
    read -r -p "Proceed? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
}

run_downloader() {
    local folder_name="$1" id

    echo
    for id in "${TO_DOWNLOAD[@]}"; do
        echo "Downloading depot ${id}..."
        "$DOWNLOADER_BIN" \
            -app "$MAIN_APP_ID" \
            -depot "$id" \
            -manifest "${DEPOT_MANIFEST[$id]}" \
            -manifestfile "$DATA_DIR/${id}_${DEPOT_MANIFEST[$id]}.manifest" \
            -depotkeys "$DATA_DIR/${MAIN_APP_ID}.keys"
        echo "Depot ${id} completed."
        echo
    done

    echo "Process finished."
}

main() {
    [[ -x "$DOWNLOADER_BIN" ]] || die "DepotDownloaderMod not found or not executable."

    parse_args "$@"

    LUA_FILE="$(find_lua_file "$TARGET_PATH")"
    mapfile -t MANIFEST_FILES < <(find_manifest_files "$TARGET_PATH")
    [[ ${#MANIFEST_FILES[@]} -gt 0 ]] || die "No .manifest files found."

    MAIN_APP_ID="$(extract_main_app_id "$LUA_FILE")"
    APP_NAME="$(extract_app_name "$LUA_FILE" "$MAIN_APP_ID")"

    parse_lua "$LUA_FILE"
    verify_manifests_present "$TARGET_PATH"
    prepare_data_dir "$TARGET_PATH"

    print_summary
    prompt_depot_selection
    print_selection_and_collect

    [[ ${#TO_DOWNLOAD[@]} -gt 0 ]] || die "No depots selected for download."

    confirm_or_exit
    run_downloader "$(basename "$TARGET_PATH")"
}

main "$@"
