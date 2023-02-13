#! /bin/bash

#returning running components + info.
ps -ef | grep 'TICK\|RDB\|RDB_AG\|CEP\|FH' | grep -v grep
