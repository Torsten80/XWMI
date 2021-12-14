#!/bin/sh

# 26.11.2021/TF
#
# simple cpu check
#
# Uebergabeparameter:
# $1: host
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

CRIT=90
WARN=80

if  [[ $2 ]] ; then
 WARN=$2
fi
if  [[ $3 ]] ; then
 CRIT=$3
fi




mydir=`dirname $0`

MYTEMP=`$mydir/wmiquery.sh $1  cpu3.qry | sed 's/|//g' | sed 's/ //g'| tail -n 1 `


if  [[ ! $MYTEMP ]] ; then
   echo "UNKNOWN:! $MYTEMP got no value"
   exit $STATE_UNKNOWN
fi

if  [[ $MYTEMP -gt $CRIT ]] ; then
   echo "Critical:! PercentProcessorTime $MYTEMP% |'PercentProcessorTime %'=$MYTEMP;$WARN;$CRIT" 
   exit $STATE_CRITICAL
fi
      
if  [[ $MYTEMP -gt $WARN ]] ; then
   echo "Warning! PercentProcessorTime $MYTEMP% |'PercentProcessorTime %'=$MYTEMP;$WARN;$CRIT" 
   exit $STATE_WARNING
fi
      
      


echo "OK  PercentProcessorTime $MYTEMP% |'PercentProcessorTime %'=$MYTEMP;$WARN;$CRIT" 
exit $STATE_OK
