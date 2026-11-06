# script to compare datasets

import pandas as pd
import os
import sys
import datetime

from wmpl.Utils.Pickling import loadPickle
from wmpl.Trajectory.CorrelateDB import TrajectoryDatabase
from wmpl.Trajectory.CorrelateRMS import TrajectoryReduced
from wmpl.Utils.TrajConversions import datetime2JD


def compareTrajDbs(srcdir, db1, db2, reqday, maxerr=1, numdays=1, outdir=None):
    dt_beg = datetime.datetime.strptime(reqday, '%Y%m%d')
    dt_end = dt_beg + datetime.timedelta(days=numdays)

    jdt_range = [datetime2JD(dt_beg), datetime2JD(dt_end)]
    sqlstr = f'select jdt_ref, participating_stations from trajectories where jdt_ref >= {jdt_range[0]} and jdt_ref < {jdt_range[1]};'

    tdb1 = TrajectoryDatabase(srcdir, db_name=db1)
    trajs = tdb1.dbhandle.execute(sqlstr).fetchall()
    old = pd.DataFrame(trajs, columns=['jdt_ref','stations'])
    old.sort_values(by='jdt_ref', inplace=True)
    print(old.iloc[0].jdt_ref, old.iloc[-1].jdt_ref)

    tdb2 = TrajectoryDatabase(srcdir, db_name=db2)
    trajs = tdb2.dbhandle.execute(sqlstr).fetchall()
    new = pd.DataFrame(trajs, columns=['jdt_ref','stations'])
    new.sort_values(by='jdt_ref', inplace=True)
    print(new.iloc[0].jdt_ref, new.iloc[-1].jdt_ref)

    olddiffs = old.copy()
    newdiffs = new.copy()
    maxerr = maxerr/86400 # convert to days

    for _, rw in new.iterrows():
        jdt_ref = rw.jdt_ref
        stats = rw.stations
        tmpdf = olddiffs[abs(olddiffs.jdt_ref-jdt_ref) < maxerr]
        if len(tmpdf) > 0:
            tmpdf2 = tmpdf[tmpdf.stations==stats]
            if len(tmpdf2) > 0:
                olddiffs.drop(index=tmpdf.index, inplace=True)
            continue

    for _, rw in old.iterrows():
        jdt_ref = rw.jdt_ref
        stats = rw.stations
        tmpdf = newdiffs[abs(newdiffs.jdt_ref-jdt_ref) < maxerr]
        if len(tmpdf) > 0:
            tmpdf2 = tmpdf[tmpdf.stations==stats]
            if len(tmpdf2) > 0:
                newdiffs.drop(index=tmpdf.index, inplace=True)
            continue

    print(f'new {len(new)} vs gmn {len(old)}')
    print(f'max time tolerance {maxerr*86400} secs')
    print(f'{len(newdiffs)} differences left in new')
    print(f'{len(olddiffs)} differences left in old')
    if outdir is not None:
        olddiffs.to_csv(os.path.join(outdir, f'olddiffs_{reqday}.csv'), index=False)
        newdiffs.to_csv(os.path.join(outdir, f'newdiffs_{reqday}.csv'), index=False)



def getDifferent(dtval, datadir='.', outdir='.', maxerr=0.001):
    old = pd.read_csv(os.path.join(datadir, f'old_{dtval}.txt'), names=['traj'])
    new = pd.read_csv(os.path.join(datadir, f'new_{dtval}.txt'), names=['traj'])

    old['timeval']=[float(x[9:19]) for x in old.traj]
    new['timeval']=[float(x[9:19]) for x in new.traj]

    old['ctry'] = ['_'.join(sorted(x[20:].split('_'))) for x in old.traj]
    new['ctry'] = [x[20:] for x in new.traj]

    olddiffs = old.copy()
    newdiffs = new.copy()

    for _, rw in new.iterrows():
        traj = rw.traj
        ctry = rw.ctry
        timeval = rw.timeval
        tmpdf = olddiffs[olddiffs.traj == traj]
        if len(tmpdf) > 0:
            olddiffs.drop(index=tmpdf.index, inplace=True)
            continue
        tmpdf = olddiffs[olddiffs.ctry==ctry]
        if len(tmpdf) > 0:
            tmpdf = tmpdf[abs(tmpdf.timeval-timeval) < maxerr]
            if len(tmpdf) > 0:
                olddiffs.drop(index=tmpdf.index, inplace=True)
                continue

    for _, rw in old.iterrows():
        traj = rw.traj
        ctry = rw.ctry
        timeval = rw.timeval
        tmpdf = newdiffs[newdiffs.traj == traj]
        if len(tmpdf) > 0:
            newdiffs.drop(index=tmpdf.index, inplace=True)
            continue
        tmpdf = newdiffs[newdiffs.ctry==ctry]
        if len(tmpdf) > 0:
            tmpdf = tmpdf[abs(tmpdf.timeval-timeval) < maxerr]
            if len(tmpdf) > 0:
                newdiffs.drop(index=tmpdf.index, inplace=True)
                continue

    if outdir is not None:
        olddiffs.to_csv(os.path.join(outdir, f'olddiffs_{dtval}.csv'), index=False)
        newdiffs.to_csv(os.path.join(outdir, f'newdiffs_{dtval}.csv'), index=False)
    return len(old), len(new), olddiffs, newdiffs


def compareOldNewDiffs(dtval, datadir, old=None, new=None, outdir='.'):
    if old is None or new is None:
        old = pd.read_csv(os.path.join(datadir, f'olddiffs_{dtval}.csv'))
        new = pd.read_csv(os.path.join(datadir, f'newdiffs_{dtval}.csv'))

    new['trajdets'] = [getTrajDets(x, True) for x in new.traj]
    new['matched'] =[False] * len(new)
    old['trajdets'] = [getTrajDets(x, False) for x in old.traj]
    old['matched'] =[False] * len(old)
    newdiffs = new.copy()
    for idx, rw in new.iterrows():
        old['ismatched'] = [testIfIn(rw.trajdets, y) for y in old.trajdets]
        if any(old.ismatched):
            newdiffs.at[idx, 'matched'] = True
            old.loc[old.ismatched == True, ['matched']]=True
        
    olddiffs = old.copy()
    for idx, rw in old.iterrows():
        newdiffs['ismatched'] = [testIfIn(rw.trajdets, y) for y in newdiffs.trajdets]
        if any(newdiffs.ismatched):
            olddiffs.at[idx, 'matched'] = True
            newdiffs.loc[newdiffs.ismatched == True, ['matched']]=True
        
    
    olddiffs[olddiffs.matched != True].to_csv(os.path.join(outdir, f'olddiffs_{dtval}.csv'), index=False)
    newdiffs[newdiffs.matched != True].to_csv(os.path.join(outdir, f'newdiffs_{dtval}.csv'), index=False)
    return newdiffs, olddiffs


def testIfIn(idvals, testvals):
    count = 0
    for idval in idvals:
        if idval in testvals:
            count += 1
    if count > 1:
        return True
    return False


def getTrajDets(traj, new=True):
    if new:
        picklepath = os.path.expanduser(f'~/data/trajectories/{traj[:4]}/{traj[:6]}/{traj[:8]}/{traj}')
    else:
        picklepath = f'/srv/meteor/rms/gmn/extracted_data/trajectories/{traj[:4]}/{traj[:6]}/{traj[:8]}/{traj}'
    picklefile = f'{traj[:15]}_trajectory.pickle'
    #print(picklepath, picklefile)
    if os.path.isfile(os.path.join(picklepath, picklefile)):
        newtraj = loadPickle(picklepath, picklefile)
        stns = [obs.station_id for obs in newtraj.observations if obs.ignore_station is False]
        obsdts = [round(obs.jdt_ref*86400 + obs.time_data[0], 2) for obs in newtraj.observations if obs.ignore_station is False]
        idlist = [f'{s}_{j}' for s,j in zip(stns,obsdts)]
        return idlist
    else:
        return []


if __name__ == '__main__':
    if len(sys.argv) > 3:
        outdir = sys.argv[3]
    else:
        outdir = '.'
    if len(sys.argv) > 4:
        maxerr = float(sys.argv[4])
    else:
        maxerr = 0.5
    old, new, olddiffs, newdiffs = getDifferent(sys.argv[1], sys.argv[2], None, maxerr)
    compareOldNewDiffs(sys.argv[1], sys.argv[2], old=olddiffs, new=newdiffs, outdir=outdir)
    print(f'{old}, {new}, {len(olddiffs)}, {len(newdiffs)}')
