#!/bin/bash

set -o errexit
set -o nounset

# ADJUST THIS FOR YOUR SYSTEM
# note this is also specifie din the Makefile
readonly DATABASE_DIR="/mnt/DataDrive1/antismash_data/"

# handle input file
readonly INPUT_FILE=$(basename $1)
readonly INPUT_DIR=$(dirname $(readlink -f $1))
shift

# handle output file
readonly OUTPUT_DIR=$(readlink -f $1)
shift

# Links within the container
readonly CONTAINER_SRC_DIR=/input
readonly CONTAINER_DST_DIR=/output
readonly CONTAINER_DB_DIR=/databases

if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir -p ${OUTPUT_DIR}
fi

# run docker using the standad Antismash runner script. 
# note that we must supply the database directort
docker run \
    --volume ${INPUT_DIR}:${CONTAINER_SRC_DIR}:ro \
    --volume ${OUTPUT_DIR}:${CONTAINER_DST_DIR}:rw \
    --volume ${DATABASE_DIR}:${CONTAINER_DB_DIR}:ro \
    --entrypoint /usr/local/bin/run \
    --detach=false \
    --rm \
    --user=$(id -u):$(id -g) \
    antismash/antismash-dev:latest \
    ${INPUT_FILE} \
$@