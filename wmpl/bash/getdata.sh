#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')

[ "$1" == "" ] && curdir=master || curdir=$1
OUTDIR=${testdir}/${wmpltest}/${curdir}
if [ ! -d $OUTDIR ] ; then echo $curdir doesnt exist ; exit ; fi


for dt in 20261014 20261015 20261016 20261017 20261018 20261019 20261020 ; do
    $here/getukmlatest.sh $OUTDIR/data/newdata.ini $dt
    sleep 5m
    $here/getukmlatest.sh $OUTDIR/data/part2.ini $dt
done

for dt in 20261021 20261022 20261023 20261024 20261025 20261026 20261027 ; do
    $here/getukmlatest.sh $OUTDIR/data/newdata.ini $dt
    sleep 5m
    $here/getukmlatest.sh $OUTDIR/data/part2.ini $dt
done

for dt in 20261028 20261029 20261030 20261031 ; do
    $here/getukmlatest.sh $OUTDIR/data/newdata.ini $dt
    sleep 5m
    $here/getukmlatest.sh $OUTDIR/data/part2.ini $dt
done
