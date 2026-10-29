#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

[ "$1" == "" ] && inif="./newdata.ini" || inif=$1
if [ ! -f "${inif}" ] ; then echo "config file $inif not found" ; exit ; fi

echo "reading from $inif"
source <(grep = ${inif} | sed 's/ *= */=/g')
echo "Date list is $DATERANGE"
echo "Station list is $STATLIST"

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
datadir=${testdir}/${wmpltest}/newdata

pushd $datadir/ukmon-shared/matches/RMSCorrelate

for dt in $DATERANGE ; do
    echo $dt
    for stat in $STATLIST; do
        targdir=$(aws s3 ls s3://ukmda-shared/matches/RMSCorrelate/${stat}/ --profile ukmonshared | grep ${dt} | awk '{print $2}')
        aws s3 sync s3://ukmda-shared/matches/RMSCorrelate/${stat}/${targdir} ./${stat}/${targdir} --profile ukmonshared
    done
done
popd
pushd $datadir
rsync -avz ./ukmon-shared/matches/RMSCorrelate/ ../shareddata/
popd
