#!/bin/sh

# 26.11.2021/TF
#
# uptime check PASSIVE!
#
# Uebergabeparameter:
# $1: output  $2: host $3: warning $4 critical
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

CRIT=5
WARN=15

if  [[ $3 ]] ; then
 WARN=$3
fi
if  [[ $4 ]] ; then
 CRIT=$4
fi


MYTEMP1=`echo $1  | sed 's/ //g'| sed 's/|/\n/g'| tail -n 2 `

#echo "fsfsdsd= $MYTEMP1"



if  [[ ! $MYTEMP1 ]] ; then
   echo "UNKNOWN:! $MYTEMP got no value"
   exit $STATE_UNKNOWN
fi

# OK - System Uptime is 21 days 23:30:40 (31650min).

MYTMIN=$(expr $MYTEMP1 / 60)
MYHOUR=$(expr $MYTEMP1 / 3600)
MYDAY=$(expr $MYHOUR / 24)

MYMIN1=$(( $MYDAY*60 ))
MYHOUR1=$(( $MYHOUR -  24*$MYDAY))

MYMIN2=$(( $MYTMIN - $MYHOUR*60 ))
MYSEC=$(( $MYTEMP1 - $MYTMIN*60 ))


ESTATE=$STATE_OK
result="OK - System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;"

if  [[ $MYTMIN -lt $CRIT ]] ; then
   result="Critical:! System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;" 
   ESTATE=$STATE_CRITICAL
fi
      
if  [[ $MYTMIN -lt $WARN ]] ; then
   result="Warning! System Uptime is $MYDAY days $MYHOUR1:$MYMIN2:$MYSEC ($MYTMIN min) | 'Uptime Minutes'=$MYTMIN;$WARN;$CRIT;" 
   ESTATE=exit $STATE_WARNING
fi
      
      

echocmd="/bin/echo -e"
CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
$echocmd "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Uptime;$ESTATE;$result" > $CommandFile

