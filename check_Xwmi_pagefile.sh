#!/bin/sh

# 30.12.2021/TF
#
# pagefile check
#
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

ESTATE=$STATE_OK

CRIT=70
WARN=65


while getopts H:c::w:h option;
do
        case $option in
                H) hostname=$OPTARG;;
                w) WARN=$OPTARG;;
                c) CRIT=$OPTARG;;
                h) help=1;;
        esac
done


if  [ $help ] ; then
 echo "
# checks Pagefiles
Usage: check_Xwmi_pagefile.sh -H Hostname  [-w 50] [-c 80]


####List of Available Parameters
-H Hostname
-w (optional) set the warning parameter,  if 0 warning and  critical will ingnored
-c (optional) set the critical parameter
-h Print this help screen


examples:
check_pagefile.sh -H 192.20.101.15 -w 10 -c 20
"

 exit
fi



mydir=`dirname $0`

#mygb=$(( 1024*1024*1024 ))

MYSTATE1="OK"

MYTEMP1=`$mydir/wmiquery.sh $hostname pagefile.qry | tail -n +5`

E1=""
E2=""

IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))
 teststring=${a[2]} 
 MYDRIVE=${teststring// /}
  

  MYAllocatedBaseSize=${a[0]}
  MYCurrentUsage=${a[1]}
  MYPeakUsage=${a[3]}

 MYAllocatedBaseSize=${MYAllocatedBaseSize// /}
 MYCurrentUsage=${MYCurrentUsage// /}
 MYPeakUsage=${MYPeakUsage// /}

  PercentUsed=$(( $MYCurrentUsage*100 / $MYAllocatedBaseSize ))
  PercentPeakUsed=$(( $MYPeakUsage*100 / $MYAllocatedBaseSize ))

  MYSTATE="OK"


  if  [[ $PercentUsed -gt $WARN ]] ; then
    MYSTATE="Warning"
    MYSTATE1="Warning"
     if  [[ $ESTATE -ne $STATE_CRITICAL ]] ; then
      ESTATE=$STATE_WARNING
     fi    
  fi


  if  [[ $PercentUsed -gt $CRIT ]] ; then
    MYSTATE="Critical"
    MYSTATE1="Critical"
    ESTATE=$STATE_CRITICAL
  fi


  E1+="$MYSTATE - $MYDRIVE:$MYAllocatedBaseSize MB - Used:$MYCurrentUsage MB ($PercentUsed%), Peak Used:$MYPeakUsage MB ($PercentPeakUsed%) "
  E2+="'$MYDRIVE Page File Size'=$MYAllocatedBaseSize; '$MYDRIVE Used'=$MYCurrentUsage; '$MYDRIVE Utilisation'=$PercentUsed%;$WARN;$CRIT; '$MYDRIVE Peak Used'=$MYPeakUsage; '$MYDRIVE Peak Utilisation'=$PercentPeakUsed%; "

 
done

echo "Overall Status - $MYSTATE1. $E1 |$E2"
exit $ESTATE



