#!/usr/bin/env bash
set -eu -o pipefail
set -x
export LC_ALL=C

# echo to stderr
eecho() { echo "$@" 1>&2; }

usage() {
  cat <<EOF
Usage:
  bash $(basename "$0") <python-version> <requirements-file> <output-file>
Description:
  Create lambda layer zip file according to the requirements file.
Requirements:
  docker, realpath
Arguments:
  python-version    : Python version
  requirements-file : Path of pip requirements file
  output-file       : Output file path
EOF
}

# Check number of arguments
if [[ $# -ne 3 ]]; then
  usage && exit 1
fi

PYTHON_VERSION=$1
REQUIREMENTS_FILE=$2
OUTPUT_FILE=$3

if [[ ! -f ${REQUIREMENTS_FILE} ]]; then
  eecho "[ERROR] requirements file '${REQUIREMENTS_FILE}' not found."
  exit 1
fi
# Ensure the directories exist
mkdir -p "$(dirname "${REQUIREMENTS_FILE}")"
mkdir -p "$(dirname "${OUTPUT_FILE}")"

REQUIREMENTS_FILE="$(realpath "${REQUIREMENTS_FILE}")"
OUTPUT_FILE="$(realpath "$(dirname "${OUTPUT_FILE}")")/$(basename "${OUTPUT_FILE}")"
DEST_DIR="$(mktemp -d)"

(
  cd "${DEST_DIR}"
  mkdir -p python

  # Run pip install command inside the official python docker image
  docker run --rm -u "${UID}:${UID}" -v "${DEST_DIR}:/work:rw" -w /work -v "${REQUIREMENTS_FILE}:/requirements.txt" "python:${PYTHON_VERSION}" pip install -r "/requirements.txt" -t ./python >&2

  # Remove unneeded files
  find python \( -name '__pycache__' -o -name '*.dist-info' \) -type d -print0 | xargs -0 rm -rf
  rm -rf python/bin
  zip -r "${OUTPUT_FILE}" .
)
