#! /usr/bin/env bash

set -xe

RECIPE_DIR=$PWD
MODULE_DIR=`dirname $0`
LAMBDA_DIR="${RECIPE_DIR}/${MODULE_DIR}/src"

cd $LAMBDA_DIR

npm install 2>&1 > /dev/null

echo '{"result":"ok"}'
