#!/usr/bin/env bash
#-------------------------------------------------------
#    FileName    : SAR_switch.sh
#    Author      : songjinjian
#    Date        : 2021-12-02
#    Description : SAR Tool V0.0.3
#-------------------------------------------------------

#port /dev/ttyACM*
fdtty=/dev/ttyACM2
#baud rate
baud=115200

#+++++++++++++++++++++++++++++++++++++++++++++++++++
ATResponseLast=/tmp/fibocomATLast
ATResponse=/tmp/fibocomAT
displaySwitch=/tmp/fibocomATSwitch
displayPid=
defaultSARFile=/usr/local/sar_default_value
bodysaren=1
bodysarmode=0
gttasen=0

showHelp(){
    echo "Welcome to Use SAR switch tool"
    echo "Case 1: SAR switch to off"
    echo "Case 2: SAR switch to on"
    echo "Case 3: SAR switch to default"
    echo "Case 4: Help"
    echo "Case 5: Exit"
    echo "Use 5 or <Ctrl-c> to exit"
    echo ""
}

scanPort(){
    if [ ! -c $fdtty ];then
        echo "Port ($fdtty) do not exist!"
        exitDisplay
        exit 0
    fi
}

initPort(){
    stty -F ${fdtty} -echo raw speed $baud  min 0 time 1 &> /dev/null
}

sendAT(){
    command=${1}
    if [ -n "${command}" ];then
        echo -e "${command}" > ${fdtty}
    fi
    sleep 0.5s
}

display(){
    while true
    do
       scanPort
       cat $fdtty >> ${ATResponse}
       if [ -s ${ATResponse} ];then
           result="$(cat ${ATResponse})"
           echo -e "${result}" > ${ATResponseLast} 
           if [ -f ${displaySwitch} ];then
               echo -e "${result}"
           fi
           cat /dev/null > ${ATResponse}
       fi
    done
}

switchDisplay(){
    switch="$1"
    if [ -z "${switch}" ];then
        if [ -f ${displaySwitch} ];then
            rm ${displaySwitch}
        fi
    else
        touch ${displaySwitch}
    fi 
}

switchSAROn(){
    sendAT "at+bodysaren=1\r"
    sendAT "at+bodysarmode=1\r"
    sendAT "at+bodysaron=1\r"
    sendAT "at+gttasen=0\r"
}

switchSAROff(){
    sendAT "at+bodysaren=0\r"
    sendAT "at+gttasen=0\r"
}

switchSARDefault(){
    bodysaren=`cat "${defaultSARFile}"|grep "BODYSAREN"|cut -d " " -f 2` 
    if [ -z "${bodysaren}" ];then
        bodysaren="1\r"
    fi
    gttasen=`cat "${defaultSARFile}"|grep "GTTASEN"|cut -d " " -f 2` 
    if [ -z "${gttasen}" ];then
        gttasen="0\r"
    fi
    bodysarmode=`cat "${defaultSARFile}"|grep "BODYSARMODE"|cut -d " " -f 2` 
    if [ -z "${bodysarmode}" ];then
        bodysarmod="1\r"
    fi

    sendAT "at+bodysaren=${bodysaren}"
    sendAT "at+gttasen=${gttasen}"
    sendAT "at+bodysarmode=${bodysarmode}"
}

querySAR(){
    if [ -s ${defaultSARFile} ];then
        return 0;
    fi

    sendAT "at+bodysaren?\r"
    response="$(cat ${ATResponseLast})"
    echo -e "${response}" >> ${defaultSARFile}
    sendAT "at+gttasen?\r"
    response="$(cat ${ATResponseLast})"
    echo -e "${response}" >> ${defaultSARFile}
    sendAT "at+bodysarmode?\r"
    response="$(cat ${ATResponseLast})"
    echo -e "${response}" >> ${defaultSARFile}
}

deleteConf(){
    if [ -s ${defaultSARFile} ];then
        rm ${defaultSARFile}
    fi
}

checkConf(){
    if [ ! -s ${defaultSARFile} ];then
        echo "No default SAR value!"
        exitDisplay
        exit 0
    fi
}

run(){
    switchDisplay
    querySAR
    switchDisplay "true"
    showHelp
    while true
    do
        if [ -s ${ATResponse} ];then
            sleep 0.5
            continue
        fi

        read -p "Please select the case label:" cmdLine
        if [ "${cmdLine}" == "1" ];then
            checkConf
            switchSAROff
        elif [ "${cmdLine}" == "2" ];then
            checkConf
            switchSAROn
        elif [ "${cmdLine}" == "3" ];then
            checkConf
            switchSARDefault
        elif [ "${cmdLine}" == "4" ];then
            showHelp
        elif [ "${cmdLine}" == "5" ];then
            exitDisplay
            exit 0
        else
            echo "Can't support case label '${cmdLine}'"
        fi
    done
}

exitDisplay(){
    if [ -n "$displayPid" ];then
        kill $displayPid
    fi
}

main(){
    scanPort
    initPort
    display &
    displayPid=$!
    run
}

main
