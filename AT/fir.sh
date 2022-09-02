#!/usr/bin/env bash
#/usr/bin/bash
ACMNum=/dev/ttyACM2
baud=115200

displayPid=

showHelp()
 {
    echo -e "\n"
    echo "****************Welcome to my Shell Tset Fiel******************"
    echo "Select Fllowinng the Five OPtions"
    echo "option 1：send AT command 'at'"
    echo "option 2：send AT command 'ati8'"
    echo "option 3：send AT command 'ati9'"
    echo "option 4: Help"
    echo "option 5: Exit"
    echo "************************Finished*******************************"
    echo -e "\n"

 }

Init_Port()  #init port
{
	stty -F ${ACMNum} speed $baud cs8 -parenb -cstopb 
	echo  " Port ${ACMNum} Init Successfully!"

}

scanPort(){
    if [ ! -c $ACMNum ];then
        echo "Port ($ACMNum) do not exist!"
        exitDisplay
        exit 0
    fi
}

sendAT(){  # Send  the  At command
    command=${1}
    if [ -n "${command}" ];then
        echo -e "${command}" > ${ACMNum}
    fi
    sleep 0.5s
}

display(){
    while true
    do
       scanPort
       cat ${ACMNum}    
:<<comment		
		if [ att${ACMNum} ];then
			result="$(cat ${ACMNum})"
			echo -e "${result}"

		fi  
comment
    done
}

run(){

    while true
    do
        read  -p "Please select the case label:" cmdLine
        if [ "${cmdLine}" == "at" ];then
            sendAT "at\r"
        elif [ "${cmdLine}" == "ati8" ];then
            sendAT "ati8\r"
        elif [ "${cmdLine}" == "ati9" ];then
            sendAT "ati9\r"
        elif [ "${cmdLine}" == "help" ];then
            showHelp
        elif [ "${cmdLine}" == "exit" ];then
            exitDisplay
       #  elif[]
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
    showHelp
    scanPort
    Init_Port
    display &
    displayPid=$!
    run
}

main

