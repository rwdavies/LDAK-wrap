#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

${WGET_OR_CURL} http://dougspeed.com/wp-content/uploads/ldak5.linux_.zip
${WGET_OR_CURL} http://dougspeed.com/wp-content/uploads/ldak5.mac_.zip
unzip ldak5.linux_.zip
unzip ldak5.mac_.zip    





