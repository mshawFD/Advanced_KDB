#! /bin/bash

procs=('RDB' 'RDB_AG' 'CEP' 'FH' 'TICK')
if [[ $1 = "ALL" ]]; then
     echo "Killing all running processes"
      for name in "${procs[@]}"
      do
      ps aux | grep $name | grep -v grep | awk '{print $2}' | xargs kill -9
      done
      echo "All processes stopped"
else
      ps aux | grep $1 | grep -v grep | awk '{print $2}' | xargs kill -9
fi
