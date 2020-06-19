#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=2
AUDIO_SAMPLES='audio_samples'

LD_LIBRARY_PATH=./sphinx-install/lib:${LD_LIBRARY_PATH} \
    TBENCH_MAXREQS=10 TBENCH_WARMUPREQS=10 \
    taskset -c 1,3 ./decoder_server_networked -t $THREADS &

echo $! > server.pid

sleep 2

TBENCH_QPS=6 TBENCH_MINSLEEPNS=10000 TBENCH_AN4_CORPUS=${DATA_ROOT}/sphinx TBENCH_CLIENT_THREADS=1 \
    TBENCH_AUDIO_SAMPLES=${AUDIO_SAMPLES} taskset -c 0 ./decoder_client_networked &

echo $! > client.pid

wait $(cat client.pid)

# Cleanup
./kill_networked.sh
rm server.pid client.pid 
