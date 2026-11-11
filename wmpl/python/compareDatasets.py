# script to compare datasets

import pandas as pd
import os
import sys
import datetime
import argparse

from wmpl.Utils.Pickling import loadPickle
from wmpl.Trajectory.CorrelateDB import TrajectoryDatabase
from wmpl.Trajectory.CorrelateRMS import TrajectoryReduced
from wmpl.Utils.TrajConversions import datetime2JD


def loadTrajFromFolder(foldername):
    print(f'loading {foldername}')
    pickles = [ x for x in os.listdir(foldername) if '_trajectory.pickle' in x]
    trajlist = []
    for pick in pickles:
        try:
            tr = TrajectoryReduced(os.path.join(foldername, pick))
        except Exception:
            print(f'unable to load {pick}')
        trajlist.append(tr)
    trajlist.sort(key=lambda tr: tr.jdt_ref)
    print(f'loaded {len(trajlist)} trajectories')
    return trajlist


def comparePhase1Folders(folder1, folder2, maxdiff=0.5):
    trajlist1 = loadTrajFromFolder(folder1)
    trajlist2 = loadTrajFromFolder(folder2)

    # trim the two lists to cover the same time window
    jd1 = [x.jdt_ref for x in trajlist1]
    jd2 = [x.jdt_ref for x in trajlist2]
    min1 = max(min(jd1), min(jd2))
    max1 = min(max(jd1), max(jd2))
    newtr = []
    for tr in trajlist1:
        if tr.jdt_ref < min1 or tr.jdt_ref > max1:
            continue
        newtr.append(tr)
    trajlist1 = newtr.copy()
    newtr = []
    for tr in trajlist2:
        if tr.jdt_ref < min1 or tr.jdt_ref > max1:
            continue
        newtr.append(tr)
    trajlist2 = newtr.copy()

    # compare cand_ids, if present
    if trajlist1[0].cand_id is not None and trajlist2[0].cand_id is not None:
        cands1 = [x.cand_id for x in trajlist1 if x.cand_id]
        cands2 = [x.cand_id for x in trajlist2 if x.cand_id]
        if len(cands1) > 0 and len(cands2) > 0:
            c1extra = [x for x in cands1 if x not in cands2]
            c2extra = [x for x in cands2 if x not in cands1]
            c1extratr = []
            for c1e in c1extra:
                c1extratr.append([tr for tr in trajlist1 if tr.cand_id == c1e][0])
            c2extratr = []
            for c2e in c2extra:
                c2extratr.append([tr for tr in trajlist2 if tr.cand_id == c2e][0])
            print('trajs in folder1 but not folder2, based on candidate ID')
            print('=======================================================')
            print('\n'.join([x.traj_file_path for x in c1extratr]))
            print('in folder2 but not folder1')
            print('\n'.join([x.traj_file_path for x in c2extratr]))
            print('\n\n')
        return 
    else:
        print('cant use cand_ids as not present in one folder')

    # compare obs_ids, if present
    if trajlist1[0].obs_ids is not None and trajlist2[0].obs_ids is not None:
        obs1 = [x.obs_ids for x in trajlist1 if x.obs_ids]
        obs2 = [x.obs_ids for x in trajlist2 if x.obs_ids]
        if len(obs1) > 0 and len(obs2) > 0:
            c1extra = [x for x in obs1 if x not in obs2]
            c2extra = [x for x in obs2 if x not in obs1]
            c1extratr = []
            for c1e in c1extra:
                c1extratr.append([tr for tr in trajlist1 if tr.obs_ids == c1e][0])
            c2extratr = []
            for c2e in c2extra:
                c2extratr.append([tr for tr in trajlist2 if tr.obs_ids == c2e][0])
            print('trajs in folder1 but not folder2, based on observations')
            print('=======================================================')
            print('\n'.join([x.traj_file_path for x in c1extratr]))
            print('in folder2 but not folder1')
            print('\n'.join([x.traj_file_path for x in c2extratr]))
            print('\n\n')
        return 
    else:
        print('cant use obs_ids as not present in one folder')

    print('comparing by jdt_ref')
    # compare jdt_ref, participating_stations and ignored_stations
    # eliminate identical jdt_refs
    jd1 = [x.jdt_ref for x in trajlist1]
    jd2 = [x.jdt_ref for x in trajlist2]
    flt1 = [x for x in jd1 if x not in jd2]
    flt2 = [x for x in jd2 if x not in jd1]

    def jdclose(jd1, jd2):
        return True if abs((jd1-jd2)*86400) < maxdiff else False

    bkptrajlist1 = trajlist1.copy()
    bkptrajlist2 = trajlist2.copy()
    print(f'comparing {folder2} to {folder1}, showing discrepancies:')
    print('===================')
    for tr in trajlist1:
        matchtr = [x for x in trajlist2 if jdclose(x.jdt_ref, tr.jdt_ref)]
        if len(matchtr)==1:
            trajlist1.pop(trajlist1.index(tr))
        elif len(matchtr) > 1:
            print(f'{len(matchtr)} matches for {tr.traj_file_path} {tr.participating_stations}:')
            print(f'{tr.obs_ids} {tr.ign_obs_ids}')
            for tr2 in matchtr:
                print(f'    {tr2.traj_file_path} {tr2.participating_stations} {tr2.obs_ids} {tr2.ign_obs_ids}')
    trajlist1 = bkptrajlist1.copy()

    print('\n\n===================')
    print(f'comparing {folder1} to {folder2}, showing discrepancies:')
    print('===================')
    for tr in trajlist2:
        matchtr = [x for x in trajlist1 if jdclose(x.jdt_ref, tr.jdt_ref)]
        if len(matchtr)==1:
            trajlist2.pop(trajlist2.index(tr))
        elif len(matchtr) > 1:
            print(f'{len(matchtr)} matches for {tr.traj_file_path} {tr.participating_stations}:')
            print(f'{tr.obs_ids} {tr.ign_obs_ids}')
            for tr2 in matchtr:
                print(f'    {tr2.traj_file_path} {tr2.participating_stations} {tr2.obs_ids} {tr2.ign_obs_ids}')
    trajlist2 = bkptrajlist2.copy()
    print('===================')

    return 


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
    arg_parser = argparse.ArgumentParser(description="Compare Trajectory datasets")
    arg_parser.add_argument('action', type=str, metavar='ACTION', default='compare', help='Action to perform')
    arg_parser.add_argument('folder1', type=str, metavar='FOLDER1',default=None, help='First folder')
    arg_parser.add_argument('folder2', type=str, metavar='FOLDER2',default=None, help='Second folder')
    arg_parser.add_argument('-o', '--outdir', type=str, metavar='OUTDIR', help='Output dir')
    arg_parser.add_argument('-m', '--maxtimediff', type=int, metavar='MAXTIMEDIFF', help='max diff in JD to be considered a match')
    cml_args = arg_parser.parse_args()

    outdir = cml_args.outdir if cml_args.outdir else '.'
    maxtimediff = int(cml_args.maxtimediff) if cml_args.maxtimediff else 0.5

    if cml_args.action.lower() == 'compare':
        comparePhase1Folders(cml_args.folder1, cml_args.folder2, maxdiff=maxtimediff)
    else:
        old, new, olddiffs, newdiffs = getDifferent(sys.argv[1], sys.argv[2], None, maxtimediff)
        compareOldNewDiffs(sys.argv[1], sys.argv[2], old=olddiffs, new=newdiffs, outdir=outdir)
        print(f'{old}, {new}, {len(olddiffs)}, {len(newdiffs)}')
