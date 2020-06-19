#!/bin/bash

export LD_LIBRARY_PATH=/home/cc/tailbench-v0.9/xapian/xapian-core-1.2.13/install/lib

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

NSERVERS=12
QPS=100
WARMUPREQS=500
REQUESTS=2000

TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    taskset -c 0,2,4,6,8,10,12,14,16,18,20,22 ./xapian_networked_server -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki \
    -r 1000000000 &
echo $! > server.pid

sleep 5 # Wait for server to come up

TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100000 \
    TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in TBENCH_CLIENT_THREADS=4 \
    taskset -c 1,3,5,7 ./xapian_networked_client &

echo $! > client.pid

wait $(cat client.pid)

# Clean up
./kill_networked.sh 
#./kill_networked.sh  > /dev/null 2>&1
rm server.pid client.pid
