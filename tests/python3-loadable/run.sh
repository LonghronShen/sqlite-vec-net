#!/bin/bash

function get_dylib_suffix() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo ".dll"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo ".dylib"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo ".so"
    else
        echo "Unsupported OS: $OSTYPE" >&2
        exit 1
    fi
}

function get_built_file_path() {
    local lib_file_name="$1"
    local ext_suffix
    ext_suffix=$(get_dylib_suffix)
    echo "$(realpath ../../build/bin/${lib_file_name}${ext_suffix})"
}

export LD_PRELOAD="$(get_built_file_path "libsqlite3")"

python3 -m pytest --snapshot-update
python3 -m pytest
