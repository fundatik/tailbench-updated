#!/bin/bash

export LD_LIBRARY_PATH=/home/cc/tailbench-v0.9/xapian/xapian-core-1.2.13/install/lib

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

NSERVERS=1
QPS=500
WARMUPREQS=1000
REQUESTS=3000

TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    taskset -c 2 ./xapian_networked_server -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki \
    -r 1000000000 &

echo $! > ${DIR}/server.pid
sudo chrt -r -p 99 $(cat ${DIR}/server.pid)


sleep 5 # Wait for server to come up

TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100000 \
    TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in TBENCH_CLIENT_THREADS=1 \
    taskset -c 4 ./xapian_networked_client &

echo $! > ${DIR}/client.pid
sudo chrt -r -p 99 $(cat ${DIR}/client.pid)


wait $(cat client.pid)

# Clean up
./kill_networked.sh
rm server.pid client.pid
