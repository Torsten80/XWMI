#!/bin/sh

# 26.11.2021/TF
#
# check free memory
#
# parameters:
# $1: host  $2:WARN  $3:CRIT
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

CRIT=5
WARN=10

if  [[ $3 ]] ; then
 WARN=$3
fi
if  [[ $4 ]] ; then
 CRIT=$4
fi




mydir=`dirname $0`
hostname=$2
#echo "$1"

#MYTEMP1=`$mydir/wmiquery.sh $1 memory.qry | sed 's/ //g'| tail -n 1 `
#MYTEMP1=`echo $1  | sed 's/ //g'| sed 's/?/\n/g'| tail -n 2 `
MYTEMP1=`echo $1 | sed 's/ //g'| sed 's/?/\n/g' | tail -n +3`

#echo "$MYTEMP1"


if  [[ ! $MYTEMP1 ]] ; then
   echo "UNKNOWN:! $MYTEMP got no value"
   exit $STATE_UNKNOWN
fi

#echo "hallo Torsten"

a=($(echo "$MYTEMP1" | tr '|' '\n'))
#echo "=${a[4]}"
FreePhysicalMemory=${a[4]} 

FreeVirtualMemory=${a[5]}
TotalVirtualMemorySize=${a[6]}
TotalVisibleMemorySize=${a[7]}
mygb=$(( 1024*1024 ))

usedPhysicalMemory=$(( $TotalVisibleMemorySize - $FreePhysicalMemory ))

PercentFree=$(( $FreePhysicalMemory*100 / $TotalVisibleMemorySize ))

SwapSize=$(( $TotalVirtualMemorySize - $TotalVisibleMemorySize ))
SwapSize=$(( $SwapSize  / $mygb ))



## now in GB
TotalVisibleMemorySize=$(( $TotalVisibleMemorySize / $mygb ))
TotalVirtualMemorySize=$(( $TotalVirtualMemorySize / $mygb ))
FreeVirtualMemory=$(( $FreeVirtualMemory / $mygb ))
FreePhysicalMemory=$(( $FreePhysicalMemory / $mygb ))





#echo "OK - PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory  FreeVirtualMemory=$FreeVirtualMemory  TotalVirtualMemorySize=$TotalVirtualMemorySize  TotalVisibleMemorySize=$TotalVisibleMemorySize Swapsize=$SwapSize |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;"

result="OK - PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB, FreeVirtualMemory=$FreeVirtualMemory GB, TotalVirtualMemorySize=$TotalVirtualMemorySize GB, TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;"
ESTATE=$STATE_OK

if  [[ $PercentFree -lt $CRIT ]] ; then
   result="Critical:! PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB,  FreeVirtualMemory=$FreeVirtualMemory GB,  TotalVirtualMemorySize=$TotalVirtualMemorySize GB,  TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;" 
   ESTATE=$STATE_CRITICAL
fi
      
if  [[ $PercentFree -lt $WARN ]] ; then
   result="Warning! PercentFree=$PercentFree% FreePhysicalMemory=$FreePhysicalMemory GB, FreeVirtualMemory=$FreeVirtualMemory GB, TotalVirtualMemorySize=$TotalVirtualMemorySize GB, TotalVisibleMemorySize=$TotalVisibleMemorySize GB, Swapsize=$SwapSize GB |'Physical Memory Used'=$usedPhysicalMemory Bytes; 'Physical Memory Free'=$PercentFree%;$WARN;$CRIT;" 
   ESTATE=$STATE_WARNING
fi




echocmd="/bin/echo -e "
CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
#echo    "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$hostname;physical Memory free;$ESTATE;$result"
#echo "hallo ballo"
echo -e "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$hostname;physical Memory free;$ESTATE;$result" > $CommandFile
