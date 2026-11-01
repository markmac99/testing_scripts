#!/bin/bash
here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source <(grep = $here/../pwsh/testing.ini | sed 's/ *= */=/g')

$here/getukmlatest.sh $here/newdata.ini 20261009
sleep 20m
$here/getukmlatest.sh $here/part2.ini 20261009
sleep 10m

$here/getukmlatest.sh $here/newdata.ini 20261010
sleep 15m
$here/getukmlatest.sh $here/part2.ini 20261010
sleep 15m

$here/getukmlatest.sh $here/newdata.ini 20261011
sleep 15m
$here/getukmlatest.sh $here/part2.ini 20261011
sleep 15m

$here/getukmlatest.sh $here/newdata.ini 20261012
sleep 15m
$here/getukmlatest.sh $here/part2.ini 20261012
sleep 15m

$here/getukmlatest.sh $here/newdata.ini 20261013
sleep 15m
$here/getukmlatest.sh $here/part2.ini 20261013
sleep 15m
