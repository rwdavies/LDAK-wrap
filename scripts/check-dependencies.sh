#!/usr/bin/env bash

set -e

command -v python3 >/dev/null 2>&1 || { echo >&2 "I require python3 but it's not installed.  Aborting."; exit 1; }
command -v R >/dev/null 2>&1 || { echo >&2 "I require R but it's not installed.  Aborting."; exit 1; }

