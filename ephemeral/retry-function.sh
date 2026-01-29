#!/bin/bash

# retry() function: Retries a given command up to 'retries' times with a 'wait' interval.
# Usage: retry <command>
# Example: retry my_api_call_function
retry() {
    local retries=5
    local count=0
    local wait=5
    local output
    while [ $count -lt $retries ]; do
        # We disable set -e for the command and capture its output.
        output=$(set +e; "$@")
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "$output"
            return 0
        fi
        count=$((count + 1))
        echo "Command failed with exit code $exit_code. Retrying in $wait seconds... ($count/$retries)" >&2
        sleep $wait
    done
    echo "Command failed after $retries retries." >&2
    echo "$output" # Also return the output of the last failed attempt for debugging
    return 1
}

# Helper function to check for a JSON error response from the API
# Usage: check_for_api_error "<response_body>" "<context_message>"
check_for_api_error() {
    local response="$1"
    local context_message="$2"
    if echo "$response" | jq -e 'if type == "object" and has("error") then true else false end' > /dev/null; then
      echo "API error during '$context_message': $response" >&2
      return 1
    fi
    return 0
}