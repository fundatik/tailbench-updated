#!/usr/bin/python

import sys
import os
import numpy as np
from scipy import stats

class Lat(object):
    def __init__(self, fileName):
        f = open(fileName, 'rb')
        a = np.fromfile(f, dtype=np.uint64)
        self.reqTimes = a.reshape((a.shape[0]/3, 3))
        f.close()

    def parseQueueTimes(self):
        return self.reqTimes[:, 0]

    def parseSvcTimes(self):
        return self.reqTimes[:, 1]

    def parseSojournTimes(self):
        return self.reqTimes[:, 2]

if __name__ == '__main__':
    def getLatPct(latsFile):
        assert os.path.exists(latsFile)

        latsObj = Lat(latsFile)

        qTimes = [l/1e6 for l in latsObj.parseQueueTimes()]
        svcTimes = [l/1e6 for l in latsObj.parseSvcTimes()]
        sjrnTimes = [l/1e6 for l in latsObj.parseSojournTimes()]
        f = open('lats.txt','w')

        f.write('%12s | %12s | %12s\n\n' \
                % ('QueueTimes', 'ServiceTimes', 'SojournTimes'))

        for (q, svc, sjrn) in zip(qTimes, svcTimes, sjrnTimes):
            f.write("%12s | %12s | %12s\n" \
                    % ('%.3f' % q, '%.3f' % svc, '%.3f' % sjrn))
        f.close()

        p99 = stats.scoreatpercentile(qTimes, 99)
        p95 = stats.scoreatpercentile(qTimes, 95)
        maxLat = max(qTimes)
        avg = np.mean(qTimes)

        svc_p99 = stats.scoreatpercentile(svcTimes, 99)
        svc_p95 = stats.scoreatpercentile(svcTimes, 95)
        svc_maxLat = max(svcTimes)
        svc_avg = np.mean(svcTimes)

        sjrn_p99 = stats.scoreatpercentile(sjrnTimes, 99)
        sjrn_p95 = stats.scoreatpercentile(sjrnTimes, 95)
        sjrn_maxLat = max(sjrnTimes)
        sjrn_avg = np.mean(sjrnTimes)

        print( "qTimes, %.3f, %.3f, %.3f, %.3f, svcTimes, %.3f, %.3f, %.3f, %.3f, sjrnTimes, %.3f, %.3f, %.3f, %.3f"% (avg, p95, p99, maxLat,svc_avg, svc_p95, svc_p99, svc_maxLat,sjrn_avg, sjrn_p95, sjrn_p99, sjrn_maxLat))

    latsFile = sys.argv[1]
    getLatPct(latsFile)
        
