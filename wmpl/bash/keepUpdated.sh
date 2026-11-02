#!/bin/bash

# script to keep the data up to date

here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

testdir=$(echo $TESTDIR  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')
wmpltest=$(echo $WMPL_TEST  | tr -d "\n\r" | sed 's|e:|/mnt/e|g')

[ "$1" == "" ] && curdir=master || curdir=$1
inidir=${testdir}/${wmpltest}/${curdir}/data
if [ ! -d $inidir ] ; then echo $curdir doesnt exist ; exit ; fi

yest=$(date --date "2 days ago" +%Y%m%d)
tod=$(date --date "1 days ago" +%Y%m%d)

$here/getlatest.sh $inidir/newdata.ini $yest
$here/getlatest.sh $inidir/newdata.ini $tod
sleep 5m
$here/getlatest.sh $inidir/part2.ini $yest
$here/getlatest.sh $inidir/part2.ini $tod
