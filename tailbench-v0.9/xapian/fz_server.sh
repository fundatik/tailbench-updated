#!/bin/bash


export LD_LIBRARY_PATH=/home/cc/tailbench-v0.9/xapian/xapian-core-1.2.13/install/lib

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

NSERVERS=$1
QPS=$3
WARMUPREQS=1000
REQUESTS=6000
CORES=$2
stat_file="stats2.txt"

export OMP_NUM_THREADS=${NSERVERS};

TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    taskset -c ${CORES} ./xapian_networked_server \
	-n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki -r 1000000000 &

sleep 10 # Wait for server to come up

ssh cc@10.140.83.245 "cd /home/cc/tailbench-v0.9/xapian/;TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100000 TBENCH_SERVER=10.140.81.248 TBENCH_TERMS_FILE=//home/cc/tailbench.inputs/xapian/terms.in taskset -c 0,2,4,6,8,10,12,14,16,18,20,22 ./xapian_networked_client "
#echo $! > server.pid
#sudo chrt -r -p 99 $(cat ${DIR}/server.pid)
#wait $(cat server.pid)
wait

# Clean up
./kill_networked.sh 

sftp -b get-lat.txt cc@10.140.83.245
v=$(python2 ../utilities/parselats.py lats.bin)
echo ${NSERVERS},${QPS},$v >>results/${stat_file}
rm lats.bin
rm lats.txt
#mv lats.bin results/${QPS}_lats.bin
#mv lats.txt results/${QPS}_lats.txt
#ls results
#cat results/stats.txt


#./kill_networked.sh  > /dev/null 2>&1
#rm server.pid
