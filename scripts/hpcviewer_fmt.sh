#! /bin/bash

# **********************************************************
# Copyright (c) 2020-2021 Xuhpclab. All rights reserved.
# Licensed under the MIT License.
# See LICENSE file for more information.
# **********************************************************

# hpcviewer_fmt.sh <application_bin_dir> <application_src_dir> <log_search_dir>

CUR_DIR=$(pwd)
DEBUG_MODE=false
HPCTOOLKIT_RUN=$(which hpcrun)
if [ ! -n "${HPCTOOLKIT_RUN}" ];then
    echo "Please install Hpctoolkit first (http://hpctoolkit.org/software-instructions.html)"
    exit -1
fi
HPCTOOLKIT_BIN_DIR=$(dirname "${HPCTOOLKIT_RUN}")
HPCTOOLKIT_LIBEXEC_DIR=$(dirname "${HPCTOOLKIT_RUN}")/../libexec
HPCSTRUCT=${HPCTOOLKIT_BIN_DIR}/hpcstruct
HPCPROF=${HPCTOOLKIT_BIN_DIR}/hpcprof
APP_BIN_FULL_PATH=$(which $1)
if [ ! -n "${APP_BIN_FULL_PATH}" ];then
    echo "Please input a vaild application name"
    exit -1
fi
APP_NAME=$(basename "${APP_BIN_FULL_PATH}")
SRC_DIR=$2
if [ ! -n "${SRC_DIR}" ];then
    echo "Please input the application's source code directory"
fi
LOG_SEARCH_DIR=$3
if [ ! -n "${LOG_SEARCH_DIR}" ];then
    LOG_SEARCH_DIR=${CUR_DIR}
fi

cd ${LOG_SEARCH_DIR}
LOG_SEARCH_DIR=$(pwd)
MEASUREMENTS_DIR=${LOG_SEARCH_DIR}/hpctoolkit-${APP_NAME}-measurements
if [ ! -n "${MEASUREMENTS_DIR}" ];then
    echo "No measurements data (hpctoolkit-${APP_NAME}-measurements) generated by DrCCTProf was found in ${LOG_SEARCH_DIR}"
    exit -1
fi

if [ "$DEBUG_MODE" == "true" ] ; then
    HPCPROFTT=${HPCTOOLKIT_LIBEXEC_DIR}/hpctoolkit/hpcproftt
    MEASUREMENTS=$(ls ${MEASUREMENTS_DIR})
    for MEASUREMENT in ${MEASUREMENTS}
    do
        echo "${HPCPROFTT} ${MEASUREMENTS_DIR}/${MEASUREMENT} > ${LOG_SEARCH_DIR}/${MEASUREMENT}.tt.log" 
        ${HPCPROFTT} ${MEASUREMENTS_DIR}/${MEASUREMENT} > ${LOG_SEARCH_DIR}/${MEASUREMENT}.tt.log && echo -e "\033[32m----------${MEASUREMENT} PASSED---------\033[0m" || (echo -e "\033[31m---------- ${MEASUREMENT} FAILED---------\033[0m"; exit -1)
    done
fi

echo "${HPCSTRUCT} ${APP_BIN_FULL_PATH}"
${HPCSTRUCT} ${APP_BIN_FULL_PATH}

echo "${HPCPROF} -S ${APP_NAME}.hpcstruct -I ${SRC_DIR} ${MEASUREMENTS_DIR}"
${HPCPROF} -S ${APP_NAME}.hpcstruct -I ${SRC_DIR} ${MEASUREMENTS_DIR}
if [ "$DEBUG_MODE" == "false" ] ; then
    rm -rf ${APP_NAME}.hpcstruct
fi

DATABASE_DIR_NAME=hpctoolkit-${APP_NAME}-database
echo -e "\033[32mSuccess generate hpcviewer datebase directory(\033[34m${LOG_SEARCH_DIR}/${DATABASE_DIR_NAME}\033[32m).\033[0m"