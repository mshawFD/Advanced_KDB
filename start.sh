#! /bin/bash

logdir=$HOME/Exercise_1/logdir/

mkdir -p $logdir

#logfile initialisation
logfile_init() 
{
if [[ -f $1 ]]; then
    newfile=$(echo "$1" | cut -f 1 -d '.')
    timestamp=$(date "+%Y%m%d%H%M%S")
    mv $1 $newfile.$timestamp.log
    echo "---- initialising new log file ----" > $1 
else
    echo "---- initialising new log file ----" > $1 
fi
}


#process specific function
startTICK()
{
TICKlog=$logdir/TICK.log
logfile_init $TICKlog
nohup q $HOME/Exercise_1/tick.q sym $HOME/Exercise_1/tplogs/ -p 5020 -name "TICK" >> $TICKlog 2>&1 &
}
startRDB()
{
RDBlog=$logdir/RDB.log 
logfile_init $RDBlog
nohup q $HOME/Exercise_1/tick/rdb.q :5020 -p 5021 -name "RDB" >> $RDBlog 2>&1 &
}
startRDB_AG()
{
RDB_AGlog=$logdir/RDB_AG.log
logfile_init $RDB_AGlog
nohup q $HOME/Exercise_1/tick/rdb_ag.q :5020 -p 5022 -name "RDB_AG" >> $RDB_AGlog 2>&1  &
}
startCEP()
{
CEPlog=$logdir/CEP.log
logfile_init $CEPlog
nohup q $HOME/Exercise_1/tick/CEP.q :5020 -p 5023 -name "CEP" >> $CEPlog 2>&1  &
}
startFH()
{
FHlog=$logdir/FH.log
logfile_init $FHlog
nohup q $HOME/Exercise_1/tick/fh.q :5020 -p 5025 -name "FH" >> $FHlog 2>&1  &
}

#function for starting all processes at once
startUp_AllProcesses()
{
echo "starting up all q processes"
startTICK
sleep 5
echo "tickerplant started up"
startRDB
startCEP
startRDB_AG
echo "All real time subscribers started"
sleep 5
startFH
echo "feed handler publishing data"
}

#function for starting one specified process
startUp_OneProcess()
{
if [[ $1 = "TICK" ]]; then
     echo "starting up tickerplant process"
     startTICK
elif [[ $1 = "RDB" ]]; then
     echo "starting up rdb process"
     startRDB
elif [[ $1 = "RDB_AG" ]]; then
     echo "starting up rdb_ag process"
     startRDB_AG
elif [[ $1 = "FH" ]]; then
     echo "starting up feedhandler process"
     startFH
elif [[ $1 = "CEP" ]]; then
     echo "starting up CEP process"
     startCEP
else
     echo "argument entered not recognised, please choose from list below:"
     echo "ALL"
     echo "TICK"
     echo "RDB"
     echo "RDB_AG"
     echo "CEP"
     echo "FH"
     exit 1
fi
}

if [[ $1 = "ALL" ]]; then
     startUp_AllProcesses
else
     startUp_OneProcess $1
fi

