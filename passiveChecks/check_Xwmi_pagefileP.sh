#!/bin/sh

# 30.12.2021/TF
#
# pagefile check
#
#
# 13.01.2022 change of default  CRIT 70->98 and WARN 65->95
#

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

ESTATE=$STATE_OK

CRIT=98
WARN=90



hostname=$2

mydir=`dirname $0`

#mygb=$(( 1024*1024*1024 ))

MYSTATE1="OK"

#MYTEMP1=`$mydir/wmiquery.sh $hostname pagefile.qry | tail -n +5`
#echo "fsfsdsd= $1"
#echo "_______"




# xx=`echo $1 |  sed  's//?/'`


#MYTEMP1=`echo $1  | sed 's/ //g'| sed 's/?/\n/g'| tail -n 2 `
MYTEMP1=`echo $1 | sed 's/ //g'| sed 's/?/\n/g' |  tail -n +4`


#MYTEMP1=`echo $MYTEMP1 | sed 's/AllocatedBaseSize//g'`

#AllocatedBaseSize 7679|4309|C:\pagefile.sys|4705| |70000|4299|Z:\pagefile.sys|4500|
#echo "$MYTEMP1"




E1=""
E2=""

IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
#echo "$x" 
 a=($(echo "$x" | tr '|' '\n'))
 teststring=${a[2]} 
 MYDRIVE=${teststring// /}
 
# echo "${a[0]} ${a[1]} ${a[2]} ${a[3]} ${a[4]} ${a[5]} ${a[6]} ${a[7]} ${a[8]} ${a[9]}"  

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


result="Overall Status - $MYSTATE1. $E1 |$E2"

echocmd="/bin/echo -e "
CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
#echo "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$hostname;Pagefile;$ESTATE;$result" 
echo -e "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$hostname;Pagefile;$ESTATE;$result" > $CommandFile
#$echocmd "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$hostname;Pagefile;$ESTATE;$result" >> $CommandFile




