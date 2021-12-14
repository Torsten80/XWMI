#/bin/sh

# 01.12.2021/TF
#
# check is SEMS is running
#
# Uebergabeparameter:
# $1: host
#
# https://github.com/SecureAuthCorp/impacket/blob/master/examples/wmiquery.py

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

MYTEMP1=`$mydir/wmiquery.sh $1 eventlogsrv.qry | sed 's/|//g' | sed 's/ //g'| tail -n 1 `


if  [[ ! $MYTEMP1 ]] ; then
   echo "UNKNOWN:! $MYTEMP got no value"
   exit $STATE_UNKNOWN
fi


#echo "$MYTEMP1"

if  [[ $MYTEMP1 != "Running" ]] ; then
   echo "Critical:! SEMS is $MYTEMP1" 
   exit $STATE_CRITICAL
fi
      

echo "OK - SEMS is $MYTEMP1 " 
exit $STATE_OK
