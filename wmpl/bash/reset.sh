#!/bin/bash

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


activate() {
echo "$(date --rfc-3339=seconds) activating $1"
ls -1d UK* | while read i 
	do ls -1 $i | grep $1 | while read j 
		do newn=$(echo $j | sed 's/ign_//g') && mv $i/$j $i/$newn 
	done  
done
}

cd $here
pwd
rm -Rf phase1 candidates trajectories *.db
cd data 
pwd
ls -1d UK* | while read  i
	do ls -1 $i | egrep -v "202607|202608|ign_" | while read j 
		do mv $i/$j $i/ign_$j  
	done
done

sleep 2m
activate 20260917
sleep 8m

activate 20260918
sleep 8m

activate 20260919
sleep 8m

activate 20260920
sleep 8m

activate 20260921
sleep 8m

activate 20260922
