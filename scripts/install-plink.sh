#!/usr/bin/env bash

set -e
script_dir=`dirname "$0"`
cd "${script_dir}"/../

if [ "${USER_OS}" == "Darwin" ]
then
    ${WGET_OR_CURL} http://s3.amazonaws.com/plink2-assets/plink2_mac_20180416.zip
    unzip plink_mac.zip    
else
    ${WGET_OR_CURL} http://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20180416.zip
    unzip plink_linux_x86_64.zip
fi


