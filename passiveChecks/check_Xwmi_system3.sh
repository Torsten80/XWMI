#!/bin/sh

# 03.03.2022/TF
#
# one check for more .. them passive
#
# Uebergabeparameter:
# 
#
#  
#


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4


CRIT=5
WARN=15

options=$@

# An array with all the arguments
arguments=($options)

# Loop index
index=0

for argument in $options
   do
     # Incrementing index
     index=`expr $index + 1`

     # The conditions
     case $argument in
       -Dw) Dw=${arguments[index]} ;;
       -Dc) Dc=${arguments[index]} ;;
       -DExclude) DExclude=${arguments[index]} ;;
       -Pw) Pw=${arguments[index]} ;;
       -Pc) Pc=${arguments[index]} ;;
       -Cw) Cw=${arguments[index]} ;;
       -Cc) Cc=${arguments[index]} ;;
       -Uw) Uw=${arguments[index]} ;;
       -Uc) Uc=${arguments[index]} ;;
       -Tw) Tw=${arguments[index]} ;;
       -Tc) Tc=${arguments[index]} ;;
       -Mw) Mw=${arguments[index]} ;;
       -Mc) Mc=${arguments[index]} ;;
        -H) hostname=${arguments[index]} ;;
        -I) hostip=${arguments[index]} ;;
     esac
   done


mydir=`dirname $0`


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

check_timediff () {

 CRIT=30
 WARN=15

 if  [[ $3 ]] ; then
  WARN=$4
 fi
 if  [[ $4 ]] ; then
  CRIT=$4
 fi

 MYTEMP5=`echo $1 | sed 's/ //g'`


 j=0
 IFS=$'|'
 a=$MYTEMP5
 for xT in $a
 do
 ((j++))
  if  [[ "$j" -eq "9" ]] ; then MYDAY=$xT  
  fi
  if  [[ "$j" -eq "10" ]] ; then MYHOUR=$xT  
  fi
  if  [[ "$j" -eq "11" ]] ; then MYMINUTE=$xT  
  fi
  if  [[ "$j" -eq "12" ]] ; then MYMONTH=$xT  
  fi
  if  [[ "$j" -eq "13" ]] ; then MYSECOND=$xT  
  fi
  if  [[ "$j" -eq "14" ]] ; then MYYEAR=$xT  
  fi
 done



# STIME="$MYYEAR$MYMONTH$MYDAY$MYHOUR$MYMINUTE$MYSECOND"
 SSTIME=$(date -d "$MYYEAR-$MYMONTH-$MYDAY $MYHOUR:$MYMINUTE:$MYSECOND UTC" +%s)

 LTIME1=`date  +%s`
 

 STATE=$STATE_OK
 TDIFF=$(( $LTIME1 - $SSTIME ))


  if  [[ $TDIFF -gt $WARN ]] ; then
   STATE=$STATE_WARNING
  fi


  if  [[ $TDIFF -gt $CRIT ]] ; then
   STATE=$STATE_CRITICAL
  fi

 result="Timediff is: $TDIFF s |'Timediff sec'=$TDIFF;$WARN;$CRIT;"
# result="Timediff is: $TDIFF s $LTIME1 - $SSTIME|'Timediff sec'=$TDIFF;$WARN;$CRIT;"

 CommandFile="/var/lib/shinken/nagios.cmd"
 datetime=`date +%s`
 # create the command line to add to the command file
 # append the command to the end of the command file
 echo -e "[$datetime] PROCESS_SERVICE_CHECK_RESULT;$2;Time;$STATE;$result" > $CommandFile


}

#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------


MYTEMP1=`$mydir/wmiquery1.sh $hostip $mydir/wmiquery/system1.qry | tail -n +4 | sed  's/^WQL.*/§/'`

#echo "$MYTEMP1"

i=0
IFS=$'§'
arr2=$MYTEMP1
for x in $arr2
do
 ((i++))
# echo "___________________________________________\n"
############### Disk ################################
 if  [[ "$i" -eq "1" ]] ; then
  xx=`echo $x |  sed  's/\|/?/'`
# Achtung für DExclude muss $Dw $Dc angegeben werden
#echo "check_Xwmi_disksP.sh  $hostname $Dw $Dc $DExclude"
  $mydir/check_Xwmi_disksP.sh "$xx" $hostname $Dw $Dc "$DExclude" 
 fi
###############  Pagefile ################################
 if  [[ "$i" -eq "2" ]] ; then
  xx=`echo $x |  sed  's/\|/?/'`
  $mydir/check_Xwmi_pagefileP.sh "$xx" $hostname $Pw $Pc 
 fi
###############  CPU ################################ 
 if  [[ "$i" -eq "3" ]] ; then
   $mydir/check_Xwmi_cpuP.sh "$x" $hostname $Cw $Cc 
 fi
###############  Uptime #############################
 if  [[ "$i" -eq "4" ]] ; then
  $mydir/check_Xwmi_uptimeP.sh "$x" $hostname $Uw $Uc 
 fi
################ Time ################################ 
 if  [[ "$i" -eq "5" ]] ; then
 # $mydir/check_Xwmi_timeP.sh "$x" $hostname $Tw $Tc
  check_timediff  "$x" $hostname $Tw $Tc 
 fi
################ Memory ################################ 
 if  [[ "$i" -eq "6" ]] ; then
  IFS=$'§'
  xx=`echo $x |  sed  's/\|/?/'`
  $mydir/check_Xwmi_memoryP.sh "$xx" $hostname $Mw $Mc 
 fi
################ Eventlog Service ####################
 if  [[ "$i" -eq "7" ]] ; then
   MYTEMP1=`echo $x  | sed 's/ //g'| sed 's/|/\n/g'| tail -n 2 `
   if  [[ ! $MYTEMP1 ]] ; then
    echo "UNKNOWN:! $MYTEMP1 got no value"
    exit $STATE_UNKNOWN
   fi
   if  [[ $MYTEMP1 != "Running" ]] ; then
    echo "Critical:! SEMS is $MYTEMP1"
    exit $STATE_CRITICAL
  fi
  echo "OK - SEMS is $MYTEMP1 "
  exit $STATE_OK 
 fi

done


exit

