#!/usr/bin/env bash
set -e

. $IDF_PATH/export.sh >/dev/null 2>&1

exec "$@"