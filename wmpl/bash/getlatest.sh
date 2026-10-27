#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

source <(grep = ./newdata.ini | sed 's/ *= */=/g')
echo "Date list is $DATERANGE"
echo "Station list is $STATLIST"

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
datadir=${testdir}/${wmpltest}/newdata

echo $testdir $datadir
pushd $datadir

for dt in $DATERANGE ; do
    echo $dt
    for stat in $STATLIST; do
        echo $stat
        rsync -avz --relative gmn.uwo.ca:/srv/meteor-ro/rms/gmn/extracted_data/${stat}/${stat}_${dt}*/platepars_all_re* .
        rsync -avz --relative gmn.uwo.ca:/srv/meteor-ro/rms/gmn/extracted_data/${stat}/${stat}_${dt}*/FTPdetect* .
    done 
done 
rsync -avz srv/meteor-ro/rms/gmn/extracted_data/ ../shareddata/
popd
