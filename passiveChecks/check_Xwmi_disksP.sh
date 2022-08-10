#!/bin/sh

# 26.11.2021/TF
#
# uptime check
#
# parameters:
# $1: host $2: warning $3 critical $4 exclude drives (C:,D:)
#
# bei exclude muss waring und clritical mitgegeben werden 
#
# - 08.03.2022 shellcheck
#
#



STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

ESTATE=$STATE_OK

CRIT=5
WARN=10

if  [[ $3 ]] ; then
 WARN=$3
fi
if  [[ $4 ]] ; then
 CRIT=$4
fi

 EXCLUDE=""
if  [[ $5 ]] ; then
 EXCLUDE=$5
fi

Caption="Caption:"
EXCLUDE="$EXCLUDE$Caption"
#echo $EXCLUDE


mygb=$(( 1024*1024*1024 ))


#echo "--- $1 ---"

#MYTEMP1=`echo $1 disks.qry | grep -v "None"  | tail -n +4`
#MYTEMP1=`echo $1 | sed 's/ //g'| sed 's/?/\n/g'| grep -v "None" `
MYTEMP1=`echo $1 | sed 's/ //g'| sed 's/?/\n/g'| grep -v "None"  | tail -n +2`
#MYTEMP1=`echo $1   sed 's/\?/XX/g' `
#MYTEMP1=`echo $MYTEMP1 | tail -n +4 `
#echo "++++++++++++++++++++"
#echo "$MYTE MP1"
#exit 
E1=""
E2=""

IFS=$'\n'
arr2=$MYTEMP1
for x in $arr2
do
 a=($(echo "$x" | tr '|' '\n'))
 # a=($(echo "$MYTEMP1" | tr '|' ' '))
 # ${entry}
# MYDRIVE=${a[0]}
# echo "--$MYDRIVE--"
# echo ${EXCLUDE} | grep --quiet ${MYDRIVE}
 teststring=${a[0]} 
 MYDRIVE=${teststring// /}
# echo "--$teststring--"
# echo "--$MYDRIVE--XX"
  
 echo ${EXCLUDE} | grep --quiet "${MYDRIVE}"
 if [ $? == 1 ] ; then

  MYSPACE=${a[3]}
  MYFREE=${a[2]}
  MYUSED=$(( $MYSPACE - $MYFREE ))
  MYSPACE1=$(( $MYSPACE / $mygb ))

  # MYFREE1=$(( $MYFREE / $mygb ))
  # MYUSED1=$(( $MYUSED / $mygb ))
  MYFREE1=`echo "scale=2;   $MYFREE / $mygb" | bc`
  MYUSED1=`echo "scale=2;   $MYUSED / $mygb" | bc`
  MYSPACE1=`echo "scale=2;  $MYSPACE / $mygb" | bc` 
  # PercentFree=$(( $MYFREE1*100 / $MYSPACE1 ))
  # PercentUsed=$(( $MYUSED1*100 / $MYSPACE1 ))
  PercentUsed=`echo "scale=2;  $MYUSED*100 / $MYSPACE" | bc`
  PercentFree=`echo "scale=2;  $MYFREE*100 / $MYSPACE" | bc`
  #echo "MYSPACE=$MYSPACE1 MYFREE=$MYFREE1 MYUSED=$MYUSED1 PFree=$PercentFree PercentUsed=$PercentUsed"

  PercentFreeINT=${PercentFree%.*}   
  #echo "PercentFreeINT=$PercentFreeINT  ... $PercentFreeINT   -lt $CRIT"

  MYSTATE="OK"



  if  [[ $PercentFreeINT -lt $WARN ]] ; then
    MYSTATE="Warning"
     if  [[ $ESTATE -ne $STATE_CRITICAL ]] ; then
      ESTATE=$STATE_WARNING
     fi    
  fi


  if  [[ $PercentFreeINT -lt $CRIT ]] ; then
    MYSTATE="Critical"
    ESTATE=$STATE_CRITICAL
  fi


  E1+="$MYSTATE - $MYDRIVE Total=$MYSPACE1 GB, Used=$MYUSED1 GB ($PercentUsed%), Free=$MYFREE1 GB ($PercentFree%) "
#  E2+="'$MYDRIVE Space'=$MYUSED1 GB; '$MYDRIVE Utilisation'= $PercentUsed%;$WARN,$CRIT; "
  E2+="'$MYDRIVE Space used'=$MYUSED1; '$MYDRIVE Utilisation'=$PercentUsed%;$WARN;$CRIT; "
 fi
 
done

result="$E1 |$E2"
#exit $ESTATE

CommandFile="/var/lib/shinken/nagios.cmd"
# get the current date/time in seconds since UNIX epoch
datetime=`date +%s`
# create the command line to add to the command file
# append the command to the end of the command file
#echo  "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Passive_Test;$ESTATE;$result"
echo -e "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Disks Space;$ESTATE;$result" > $CommandFile


