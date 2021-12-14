#!/bin/sh
# 26.11.2021/TF
#
# uptime check
#
# Uebergabeparameter:
# $1: host $2: warning $3 critical
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

CRIT=5
WARN=15

if  [ $2 ] ; then
 WARN=$2
fi
if  [ $3 ] ; then
 CRIT=$3
fi




mydir=`dirname $0`

MYTEMP1=`$mydir/wmiquery.sh $1 uptime.qry | sed 's/|//g' | sed 's/ //g'| tail -n 1 `
#echo "$MYTEMP1"



if  [[ ! $MYTEMP1 ]] ; then
   echo "UNKNOWN:! $MYTEMP1 got no value"
   exit $STATE_UNKNOWN
fi


MYTMIN=$(expr $MYTEMP1 / 60)
MYHOUR=$(expr $MYTEMP1 / 3600)
MYDAY=$(expr $MYHOUR / 24)

MYHOUR1=$(( $MYHOUR -  24*$MYDAY))

MYMIN2=$(( $MYTMIN - $MYHOUR*60 ))
MYSEC=$(( $MYTEMP1 - $MYTMIN*60 ))



if  [[ $MYTMIN -lt $CRIT ]] ; then
   echo "Critical:! System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;" 
   exit $STATE_CRITICAL
fi
      
if  [[ $MYTMIN -lt $WARN ]] ; then
   echo "Warning! System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;" 
   exit $STATE_WARNING
fi
      
      
echo "OK - System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;"

exit $STATE_OK
