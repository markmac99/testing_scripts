# powershell script to run some basic WMPL tests

# This version loads local data and creates candidates

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

$targdir="$loc\localmaster"
if (-not (test-path $targdir)) {mkdir $targdir}

$datadir = "${loc}\data"
if (-not (test-path $datadir)) {mkdir $datadir}

if ($args[0] -eq "init")
{
  Write-Output "initialising"
  pushd $targdir
  if (test-path trajectories.db) {remove-item trajectories.db}
  if (test-path observations.db) {remove-item observations.db}
  if (test-path candidates.db) {remove-item candidates.db}
  if (test-path processed_trajectories.json) {remove-item processed_trajectories.json}
  if (test-path trajectories) {Remove-Item -recurse trajectories}
  if (test-path phase1) {Remove-Item -recurse phase1}
  if (test-path candidates) {remove-item -recurse candidates}
  popd
} else {
  echo "Rerunning"
}

python -m wmpl.Trajectory.CorrelateRMS $datadir -a 21 --autofreq 30 --cpucores 4 --logdir $targdir/logs  --outdir $targdir --dbdir $targdir --maxstations 6 --mcmode 1 --archivemonths  0 --addlogsuffix

cd $here
$host.ui.RawUI.WindowTitle = "Powershell"