#!/bin/bash

export LD_LIBRARY_PATH=/home/cc/tailbench-v0.9/xapian/xapian-core-1.2.13/install/lib

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

QPS=500

nr_cores="1"
cores="0"

TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100000 TBENCH_SERVER=10.140.81.248 \
    TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in TBENCH_CLIENT_THREADS=$nr_cores \
    taskset -c $cores ./xapian_networked_client &

#echo $! > ${DIR}/client.pid
#sudo chrt -r -p 99 $(cat ${DIR}/client.pid)
echo $! > client.pid
#sudo chrt -f -p 99 $(cat client.pid)

wait $(cat client.pid)

# Clean up
#./kill_networked.sh
#./kill_networked.sh  > /dev/null 2>&1
rm client.pid
