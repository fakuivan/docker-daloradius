#!/bin/bash

check_env_not_empty() {
    local name="$1" &&
    local -n value="$name" &&
    if [[ -z "$value" ]]; then
        echo "error: Variable $name must be set to a non-empty value."
        return 1
    fi &&
    return 0
    return $?
}

for env_var in "RADIUS_DB_HOST" "RADIUS_DB_USER" "RADIUS_DB_PASS" "RADIUS_DB_NAME"; do
    check_env_not_empty "$env_var" 1>&2 || exit 1
    export "$env_var" # This should be safe if ``check_env_not_empty`` returns 0
done

if [[ -z "$RADIUS_DB_PORT" ]]; then
    export "RADIUS_DB_PORT=3306"
fi

"$@"
