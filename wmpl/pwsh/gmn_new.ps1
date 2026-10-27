# powershell script to run some basic WMPL tests

# This version is the new GMN version with separate steps for candidates and phase1

Param($config='testing.ini')

# load the helper functions
. $PSScriptRoot\helperfunctions.ps1

$ini=get-inicontent "$psscriptroot\$config"

$here = get-location

$testdir = $ini['testing']['testdir'].replace('$HOME',$home)
$wmplloc = $ini['wmpl']['wmpl_loc'].replace('$HOME',$home)
$wmplenv = $ini['wmpl']['wmpl_env']
$wmpltest = $ini['wmpl']['wmpl_test'].replace('$HOME',$home)

push-location "${testdir}/${wmpltest}"
$loc = get-location

conda activate $wmplenv
$env:pythonpath="$wmplloc;$env:pythonpath"

Push-Location $wmplloc
git checkout distrib_processing
Pop-Location

$targdir="$loc\gmn_new"
if (-not (test-path $targdir)) {mkdir $targdir}

if ($args[0] -eq "init")
{
    Write-Output "initialising"
    Push-Location $targdir
    if (test-path observations.db) {remove-item observations.db}
    if (test-path trajectories.db) {remove-item trajectories.db}
    if (test-path processed_trajectories.json){remove-item processed_trajectories.json}
    if (test-path candidates) {remove-item -recurse candidates}
    if (test-path phase1) {remove-item -recurse phase1}
    if (test-path trajectories) {remove-item -recurse trajectories}
    Pop-Location
}else{
    write-output "rerunning"
}

$datadir = "${loc}\data"

$tr = "(20260222-170000,20260227-170000)"

if ($args[0] -ne "ph1")
{
    python -m wmpl.Trajectory.CorrelateRMS $datadir --mcmode 4 --cpucores 4 --timerange "${tr}" --logdir $loc/logs --dbdir $targdir --outdir $targdir --archivemonths  0 --addlogsuffix
}
if ($args[0] -eq "ph1")
{
    python -m wmpl.Trajectory.CorrelateRMS $datadir -a --autofreq 15 --mcmode 1 --cpucores 4 --logdir $loc/logs --outdir $targdir --dbdir $targdir --archivemonths  0 --addlogsuffix 
}
set-location $here