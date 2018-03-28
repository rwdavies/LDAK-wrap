#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

if [ "${USER_OS}" == "Darwin" ]
then
    ${WGET_OR_CURL} https://www.cog-genomics.org/static/bin/plink180221/plink_mac.zip
    unzip plink_mac.zip    
else
    ${WGET_OR_CURL} https://www.cog-genomics.org/static/bin/plink180221/plink_linux_x86_64.zip
    unzip plink_linux_x86_64.zip
fi


