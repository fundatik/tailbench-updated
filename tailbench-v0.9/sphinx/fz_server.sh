#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=1
AUDIO_SAMPLES='audio_samples'

LD_LIBRARY_PATH=./sphinx-install/lib:${LD_LIBRARY_PATH} \
    TBENCH_MAXREQS=10 TBENCH_WARMUPREQS=10 \
    taskset -c 0 ./decoder_server_networked -t $THREADS &

echo $! > server.pid

wait $(cat server.pid) 

# Cleanup
#./kill_networked.sh
rm server.pid
