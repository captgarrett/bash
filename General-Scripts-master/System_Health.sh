#! /bin/bash
clear -n
echo -e "\e[1;47;100m                                  System\e[92mHealth                                  \e[0m\v"

################################################################################
##########################################################  HELPINFO  ##########
################################################################################

function helpinfo() {
cat<<EOF
                                            Report Script v1.1
      +------------------------------------------------------------------+
      |     Name : System Health                                         |
      |  Version : 1.1 (July 2019)                                       |
      |                                                                  |
      |                                                                  |
      |  Comment : System Health Summary Report                          |
      |            Improvement Feedback Welcome                          |
      |                                                                  |
      +------------------------------------------------------------------+
   Usage : $0 [option]
   Current available options :
        -s | --systeminfo       : System and kernel server details
        -c | --cpuinfo          : List of all CPU details
        -m | --memoryinfo       : List of all Memory details
        -d | --diskinfo         : Mount and physical disk details
        -n | --networkinfo      : Network, firewall details
        -f | --fullreport       : Displays the full server report
        -h | --help             : Display help information
  * Options are not available for this version, Please stay tunned.
EOF
exit 0
}

################################################################################
##################################################  GLOBAL FUNCTIONS  ##########
################################################################################

tmpfile='.system_report.tmp'

RES_COL=72
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_HEALTHY="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

function STATUS_COLOR() {
$MOVE_TO_COL
  echo -n "["
  case $1 in
        failure) $SETCOLOR_FAILURE;echo -n $"FAILURE";$SETCOLOR_NORMAL;;
        warning) $SETCOLOR_WARNING;echo -n $"WARNING";$SETCOLOR_NORMAL;;
        healthy) $SETCOLOR_HEALTHY;echo -n $"HEALTHY";$SETCOLOR_NORMAL;;
  esac
  echo -n "]"
  echo -ne "\r"
  case $1 in
        failure) return 1;;
        warning) return 2;;
        healthy) return 0;;
  esac
}

function FORMATTING_COLOR() {
  case $1 in
        failure) echo -e "\e[31m$2\e[0m";;
        warning) echo -e "\e[33m$2\e[0m";;
        healthy) echo -e "\e[32m$2\e[0m";;
  esac
}

function CHKSTATUS() {
  if [ -z "$STATUS" ];then
        STATUS="$1"
  else
        if [ ! "$STATUS" = $1 ];then
           case $1 in
                warning ) if [ ! "$STATUS" = "failure" ];then STATUS="$1";fi;;
                failure ) STATUS="$1";;
           esac
        fi
  fi
}


function TITLE() {
  echo -en "\n"
  s=$(printf "%-71s" "-")
  [ -z $2 ] && echo -ne "---------" || STATUS_COLOR $2
  echo -en "${s// /-}"
  echo -en "\r-- $1 -"
  echo -en "\n\n"
  unset STATUS
}

################################################################################
########################################################  SYSTEMINFO  ##########
################################################################################

function systeminfo() {
  declare -A SYSTEM
  SYSTEM[INFO]=`cat /etc/redhat-release`
  uptime=$(</proc/uptime);uptime=${uptime%%.*};seconds=$(( uptime%60 ));minutes=$(( uptime/60%60 ));hours=$(( uptime/60/60%24 ));days=$(( uptime/60/60/24 ))
  SYSTEM[UPTIME]=`echo "$days days, $hours hours, $minutes minutes, $seconds seconds"`
  SYSTEM[ARCH]=`uname -sp`
  SYSTEM[KERNEL]=`uname -r`
  SYSTEM[DATE]=`date`
  DATE[EASTERN]=`date -d '4 hour ago' "+%m/%d/%Y -%H:%M:%S"`

TITLE SYSTEMINFO
cat <<EOF | column -t -s';'
   Release Name;:;${SYSTEM[INFO]}
   Protect Release;:;${SYSTEM[ARCH]}
   Kernel Version;:;${SYSTEM[KERNEL]}
   Uptime;:;${SYSTEM[UPTIME]}
   Server Time;:;${SYSTEM[DATE]}
   Eastern Time;:;${DATE[EASTERN]}
EOF
}

################################################################################
###########################################################  CPUINFO  ##########
################################################################################

function cpuinfo() {
  declare -A CPU
  CPU[INFO]=`awk -F':' '/^model name/{print $2}' /proc/cpuinfo  | sed -r 's/\s{2}+//g;s/^ //g' | uniq`
  CPU[CORE]=`grep -c ^processor /proc/cpuinfo`
  CPU[STAT]=`top -b -n1 | grep 'Cpu(s)' | sed 's/.*:\s\+//' | cut -d',' -f1-5`
  CPU[LOAD]=`uptime |awk -F'average:' '{ print $2 }'| sed 's/\s//g'`
  CPU[LOAD1]=`echo ${CPU[LOAD]} | awk -F',' '{print $1}'`
  CPU[LOAD5]=`echo ${CPU[LOAD]} | awk -F',' '{print $2}'`
  CPU[LOAD15]=`echo ${CPU[LOAD]} | awk -F',' '{print $3}'`
  CPU[TASKS]=`ps -eLF wh | grep -v 'ps -eLF wh' | wc -l`
  CPU[TASKSRUN]=`ps -eLF whr | grep -v 'ps -eLF whr' | wc -l`
  CPU[TASKSLEEP]=$(( ${CPU[TASKS]} - ${CPU[TASKSRUN]} ))

  [ `echo ${CPU[LOAD1]} | cut -d'.' -f1` -ge ${CPU[CORE]} ] && CPU[LOAD1]="\e[33m${CPU[LOAD1]}\e[0m" || CPU[LOAD1]="\e[32m${CPU[LOAD1]}\e[0m"
  [ `echo ${CPU[LOAD5]} | cut -d'.' -f1` -ge ${CPU[CORE]} ] && CHKSTATUS warning && CPU[LOAD5]="\e[33m${CPU[LOAD5]}\e[0m" || CHKSTATUS healthy && CPU[LOAD5]="\e[32m${CPU[LOAD5]}\e[0m"
  [ `echo ${CPU[LOAD15]} | cut -d'.' -f1` -ge ${CPU[CORE]} ] && CHKSTATUS failure && CPU[LOAD15]="\e[31m${CPU[LOAD15]}\e[0m" || CHKSTATUS healthy && CPU[LOAD15]="\e[32m${CPU[LOAD15]}\e[0m"

TITLE CPUINFO $STATUS
echo -e "
   Processor;:;${CPU[CORE]} x ${CPU[INFO]}
   Load Average;:;${CPU[LOAD1]}, ${CPU[LOAD5]}, ${CPU[LOAD15]} (1,5,15 min)
   Tasks;:;${CPU[TASKS]} Total, ${CPU[TASKSRUN]} Running, ${CPU[TASKSLEEP]} Sleeping/waiting
   Stats;:;${CPU[STAT]}" | column -t -s';'
}

################################################################################
########################################################  MEMORYINFO  ##########
################################################################################

function memoryinfo() {
   declare -A MEMORY
   MEMORY[SIZE]=`awk '/^MemTotal/{print $2}' /proc/meminfo`
   MEMORY[FREE]=`awk '/^MemFree/{print $2}' /proc/meminfo`
   MEMORY[USED]=$((${MEMORY[SIZE]}-${MEMORY[FREE]}))
   MEMORY[%USED]=`echo "scale=2; (${MEMORY[USED]}*100)/${MEMORY[SIZE]}" | bc | sed 's/^\./0./g'`

   declare -A SWAP
   SWAP[SIZE]=`awk '/^SwapTotal/{print $2}' /proc/meminfo`
   SWAP[FREE]=`awk '/^SwapFree/{print $2}' /proc/meminfo`
   SWAP[USED]=$((${SWAP[SIZE]}-${SWAP[FREE]}))
   SWAP[%USED]=`echo "scale=2; (${SWAP[USED]}*100)/${SWAP[SIZE]}" | bc | sed 's/^\./0./g'`

   if [ `echo ${MEMORY[%USED]}| sed 's/\..*//g'` -gt "85" ];then
        CHKSTATUS warning
        MEMORY[%USED]="\e[33m${MEMORY[%USED]}%\e[0m"
   elif [ `echo ${MEMORY[%USED]}| sed 's/\..*//g'` -gt "95" ];then
        CHKSTATUS failure
        MEMORY[%USED]="\e[31m${MEMORY[%USED]}%\e[0m"
   else
        CHKSTATUS healthy
        MEMORY[%USED]="\e[32m${MEMORY[%USED]}%\e[0m"
   fi

   if [ `echo ${SWAP[%USED]}| sed 's/\..*//g'` -gt "15" ]; then
        CHKSTATUS warning
        SWAP[%USED]="\e[33m${SWAP[%USED]}%\e[0m"
   elif [ `echo ${SWAP[%USED]}| sed 's/\..*//g'` -gt "25" ];then
        CHKSTATUS failure
        SWAP[%USED]="\e[31m${SWAP[%USED]}%\e[0m"
   else
        CHKSTATUS healthy
        SWAP[%USED]="\e[32m${SWAP[%USED]}%\e[0m"
   fi

   TITLE MEMORYINFO $STATUS
   echo -e "   ; Total Size (kB); Used (kB); Free (kB); %Used
   Memory; ${MEMORY[SIZE]}; ${MEMORY[USED]}; ${MEMORY[FREE]}; ${MEMORY[%USED]}
   Swap; ${SWAP[SIZE]}; ${SWAP[USED]}; ${SWAP[FREE]}; ${SWAP[%USED]}" | column -t -s';'
}

################################################################################
##########################################################  DISKINFO  ##########
################################################################################

function diskinfo() {
   echo "   Filesystem;Type;Mounted on;Inodes;IFree;IUse%;Size;Free;Use%" > $tmpfile
   for i in `df -hPT | sed '1d' | sed 's/\s\+/;/g'`;do
        declare -A DISK
        DISK[MOUNT]=`echo $i | awk -F';' '{print $7}'`
        DISK[FILESYS]=`echo $i | awk -F';' '{print $1}'`
        DISK[TYPE]=`echo $i | awk -F';' '{print $2}'`
        DISK[SIZE]=`echo $i | awk -F';' '{print $3}'`
        DISK[USED]=`echo $i | awk -F';' '{print $4}'`
        DISK[FREE]=`echo $i | awk -F';' '{print $5}'`
        DISK[%USED]=`echo $i | awk -F';' '{print $6}' | sed 's/%//'`
        INNODE=`df -Pi ${DISK[MOUNT]} | sed '1d' | sed 's/\s\+/;/g'`
        DISK[iSIZE]=`echo $INNODE | awk -F';' '{print $2}'`
        DISK[iUSED]=`echo $INNODE | awk -F';' '{print $3}'`
        DISK[iFREE]=`echo $INNODE | awk -F';' '{print $4}'`
        DISK[%iUSED]=`echo $INNODE | awk -F';' '{print $5}' | sed 's/%//'`

        if [ `echo ${DISK[%USED]}| sed 's/\..*//g'` -gt "85" ];then
           CHKSTATUS warning
           DISK[%USED]="\e[33m${DISK[%USED]}%\e[0m"
        elif [ `echo ${DISK[%USED]}| sed 's/\..*//g'` -gt "95" ];then
           CHKSTATUS failure
           DISK[%USED]="\e[31m${DISK[%USED]}%\e[0m"
        else
           CHKSTATUS healthy
           DISK[%USED]="\e[32m${DISK[%USED]}%\e[0m"
        fi

        if [ `echo ${DISK[%iUSED]}| sed 's/\..*//g'` -gt "85" ]; then
           CHKSTATUS warning
           DISK[%iUSED]="${DISK[%iUSED]}% ??"
        elif [ `echo ${DISK[%iUSED]}| sed 's/\..*//g'` -gt "95" ];then
           CHKSTATUS failure
           DISK[%iUSED]="${DISK[%iUSED]}% !!"
        else
           CHKSTATUS healthy
           DISK[%iUSED]="${DISK[%iUSED]}%"
        fi

        echo -e "   ${DISK[FILESYS]};${DISK[TYPE]};${DISK[MOUNT]};${DISK[iSIZE]};${DISK[iFREE]};${DISK[%iUSED]};${DISK[SIZE]};${DISK[FREE]};${DISK[%USED]}" >> $tmpfile
   done

   TITLE DISKINFO $STATUS
   column -t -s';' $tmpfile
   echo ""
   rm -f $tmpfile
}

################################################################################
#######################################################  NETWORKINFO  ##########
################################################################################

function networkinfo() {

   echo "   Iface;Address;Speed;Duplex;Autoneg;RX / TX / Collision">> $tmpfile
   for i in `ip -o addr | awk '/inet /{print $2";"$4}'`;do
        declare -A NET
        NET[IFACE]=`echo $i | awk -F';' '{print $1}'`
        NET[ADDR]=`echo $i | awk -F';' '{print $2}' | sed s'/\/.*//'`
        NET[SUB]=`echo $i | awk -F';' '{print $2}' | sed s'/.*\///'`
        NET[rDNS]=`dig -x ${NET[ADDR]} +short`
        NET[SPEED]=`ethtool ${NET[IFACE]} | awk '/Speed/{print $2}'`
        NET[DUPLEX]=`ethtool ${NET[IFACE]} | awk '/Duplex/{print $2}'`
        NET[AUTONEG]=`ethtool ${NET[IFACE]} | awk '/Auto-negotiation/{print $2}'`
        NET[RX-ERRS]=`awk '/'.${NET[IFACE]}.'/{print $4}' /proc/net/dev`
        NET[TX-ERRS]=`awk '/'.${NET[IFACE]}.'/{print $12}' /proc/net/dev`
        NET[COLLS]=`awk '/'.${NET[IFACE]}.'/{print $15}' /proc/net/dev`

        [ -z ${NET[SPEED]} ] && NET[SPEED]="N/A"
        [ -z ${NET[DUPLEX]} ] && NET[DUPLEX]="N/A"
        [ -z ${NET[AUTONEG]} ] && NET[AUTONEG]="N/A"


        if [ ! "${NET[RX-ERRS]}" = '0' ];then
                CHKSTATUS failure
                NET[RX-ERRS]="\e[31m${NET[RX-ERRS]}\e[0m"
        else
                CHKSTATUS healthy
                NET[RX-ERRS]="\e[32m${NET[RX-ERRS]}\e[0m"
        fi

        if [ ! "${NET[TX-ERRS]}" = '0' ];then
                CHKSTATUS failure
                NET[TX-ERRS]="\e[31m${NET[TX-ERRS]}\e[0m"
        else
                CHKSTATUS healthy
                NET[TX-ERRS]="\e[32m${NET[TX-ERRS]}\e[0m"
        fi

        if [ ! "${NET[COLLS]}" = '0' ];then
                CHKSTATUS failure
                NET[COLLS]="\e[31m${NET[COLLS]}\e[0m"
        else
                CHKSTATUS healthy
                NET[COLLS]="\e[32m${NET[COLLS]}\e[0m"
        fi

        echo -e "   ${NET[IFACE]};${NET[ADDR]}/${NET[SUB]};${NET[SPEED]};${NET[DUPLEX]};${NET[AUTONEG]};${NET[RX-ERRS]} / ${NET[TX-ERRS]} / ${NET[COLLS]}" >> $tmpfile
   done

   TITLE NETWORKINFO $STATUS
       column -t -s';' $tmpfile
        rm -rf $tmpfile
}


################################################################################
########################################################  FULLREPORT  ##########
################################################################################

function fullreport() {
        systeminfo
        cpuinfo
        memoryinfo
        diskinfo
        networkinfo
}

################################################################################
############################################################  OUTPUT  ##########
################################################################################

if [ ! $1 = "" ]; then
   for argument in $@; do
        case "$argument" in
        -s | --systeminfo  )    systeminfo ;;
        -c | --cpuinfo     )    cpuinfo ;;
        -m | --memoryinfo  )    memoryinfo ;;
        -d | --diskinfo    )    diskinfo ;;
        -n | --networkinfo )    networkinfo ;;
        -f | --fullreport  )    fullreport ;;
        -h | --help | -\?  )    helpinfo ;;
        esac
   done
else
        fullreport
fi
echo -e '\v'
exit
