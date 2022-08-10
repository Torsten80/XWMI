#!/bin/sh

# 10.12.2021/TF
#
# check server time compared to local time
#
# parameters:
# $1: host $2: warning $3 critical 
#
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

STATE=$STATE_OK

CRIT=30
WARN=10

if  [[ $3 ]] ; then
 WARN=$4
fi
if  [[ $4 ]] ; then
 CRIT=$4
fi


mydir=`dirname $0`



MYTEMP1=`echo $1 | sed 's/ //g' `
#echo "$MYTEMP1"

LTIME=`date -u +"%Y%m%d%H%M%S"`
#echo "$LTIME"

a=($(echo "$MYTEMP1" | tr '|' '\n'))
 MYDAY=${a[6]} 
 MYHOUR=${a[7]}
 MYMINUTE=${a[8]}
 MYMONTH=${a[9]}
 MYSECOND=${a[10]}
 MYYEAR=${a[11]}
 
MYDAYL=${#MYDAY}
MYHOURL=${#MYHOUR}
MYMINUTEL=${#MYMINUTE}
MYMONTHL=${#MYMONTH}
MYSECONDL=${#MYSECOND}

 if  [[ MYDAYL -eq 1 ]] ; then   MYDAY="0"$MYDAY  
 fi
 if  [[ MYHOURL -eq 1 ]] ; then   MYHOUR="0"$MYHOUR  
 fi
 if  [[ MYMINUTEL -eq 1 ]] ; then   MYMINUTE="0"$MYMINUTE  
 fi
 if  [[ MYMONTHL -eq 1 ]] ; then   MYMONTH="0"$MYMONTH  
 fi
 if  [[ MYSECONDL -eq 1 ]] ; then   MYSECOND="0"$MYSECOND  
 fi



STIME=$MYYEAR$MYMONTH$MYDAY$MYHOUR$MYMINUTE$MYSECOND


TDIFF=$(( $LTIME - $STIME ))



  if  [[ $TDIFF -gt $WARN ]] ; then
   STATE=$STATE_WARNING
  fi


  if  [[ $TDIFF -gt $CRIT ]] ; then
   STATE=$STATE_CRITICAL
  fi



result="Timediff is: $TDIFF s|'Timediff sec'=$TDIFF;$WARN;$CRIT;"
#exit $STATE



echocmd="/bin/echo -e"
CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
$echocmd "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Time;$STATE;$result" >> $CommandFile

