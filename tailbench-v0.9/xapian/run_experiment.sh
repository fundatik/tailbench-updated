#!/bin/bash

lst_nr_cores=("1" "2" "4" "6" "8" "10" "12")
lst_core_ids=("0" "0,2" "0,2,4,6" "0,2,4,6,8,10" "0,2,4,6,8,10,12,14" "0,2,4,6,8,10,12,14,16,18" "0,2,4,6,8,10,12,14,16,18,20,22")
out="out2.txt"
MIN_QPS=100
MAX_QPS=1900

for cid in ${!lst_nr_cores[@]}; do
	for ((qps = ${MIN_QPS}; qps <= ${MAX_QPS}; qps += 100 )); do
		./fz_server.sh ${lst_nr_cores[$cid]} ${lst_core_ids[$cid]} $qps >> $out 2>&1
		res=$(tail -n 1 results/stats.txt)
		echo "${lst_nr_cores[$cid]},$qps,$res" 
	done
done
#pkill xapian_netw
