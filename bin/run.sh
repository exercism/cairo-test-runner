#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: path to solution folder
# $3: path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

slug="$1"
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

start_dir="$(pwd)"
cd "${solution_dir}" || exit 1

# Run the tests for the provided implementation file and redirect stdout and
# stderr to capture it
test_output=$(scarb cairo-test --include-ignored 2>&1)
exit_code=$?

cd "${start_dir}" || exit 1

# Write the results.json file based on the exit code of the command that was
# just executed that tested the implementation file
if [ ${exit_code} -eq 0 ]; then
    jq -n '{version: 1, status: "pass"}' >"${results_file}"
else
    # Sanitize the output
    # TODO: enable if needed to escape quotes: test_output_inline=$(printf '%s' "${test_output}" | sed -r 's/\"/\\"/g')
    test_output_inline=$(printf '%s' "${test_output}")

    # Try to distinguish between failing tests and errors
    if echo "${test_output_inline}" | grep "error:"; then
        status="error"
        sanitized_test_output=$(echo "$test_output_inline" | awk '/Compiling/{y=1;next}y' | sed -n -e '/error: could not compile/q;p')
    else
        status="fail"
        sanitized_test_output=$(echo "$test_output_inline" | awk '/failures:/{y=1;next}y' | sed -n -e '/Error: test result/q;p' | sed -r 's/   //g')
    fi

    tmp_file=$(mktemp -p .)
    trap 'rm $tmp_file' EXIT INT TERM

    printf '%s' "$sanitized_test_output" >"$tmp_file"
    sorted_output=$(sort "$tmp_file")

    jq -n --arg output "${sorted_output}" --arg status "${status}" '{version: 1, status: $status, message: $output}' >"${results_file}"
fi

echo "${slug}: done"
