#!/bin/sh

# 26.11.2021/TF
#
# simple cpu check
#
# Uebergabeparameter:
# $1: host
#
# # - 08.03.2022 shellcheck
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
ESTATE=$STATE_OK

CRIT=98
WARN=80

if  [[ $3 ]] ; then
 WARN=$3
fi
if  [[ $4 ]] ; then
 CRIT=$4
fi


#MYTEMP1=`$mydir/wmiquery.sh $1 cpu_idle.qry | sed 's/|//g' | sed 's/ //g'| tail -n 1 `
#echo $1
#echo "-------------------------"

MYTEMP1=`echo $1  | sed 's/ //g'| sed 's/|/\n/g'| tail -n 2 `

#echo "fsfsdsd= $MYTEMP1"

#exit
if  [[ ! $MYTEMP1 ]] ; then
   result="UNKNOWN:! $MYTEMP got no value"
   ESTATE=$STATE_UNKNOWN
fi

MYTEMP=$(expr 100  - $MYTEMP1)

result="OK - PercentProcessorUsage $MYTEMP% |'PercentProcessorUsage %'=$MYTEMP;$WARN;$CRIT"


      
if  [[ $MYTEMP -gt $WARN ]] ; then
   result="Warning! PercentProcessorUsage $MYTEMP% |'PercentProcessorUsage %'=$MYTEMP;$WARN;$CRIT" 
   ESTATE=$STATE_WARNING
fi



if  [[ $MYTEMP -gt $CRIT ]] ; then
   result="Critical:! PercentProcessorUsage $MYTEMP% |'PercentProcessorUsage %'=$MYTEMP;$WARN;$CRIT"
   ESTATE=$STATE_CRITICAL
fi
      
      
echocmd="/bin/echo -e"
CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
$echocmd "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;cpu PercentProcessorUsage;$ESTATE;$result" > $CommandFile


