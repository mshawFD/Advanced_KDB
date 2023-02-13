# Advanced_KDB

## Exercise 1
All Exercise 1 scripts are located in: 

```/home/mshaw_kx_com/Exercise_1```.

The tick system needs to be started up in the following order:
- Tickerplant process: `tick.q`
- RDB processes: `tick/rdb.q`,`tick/rdb_ag.q`,`tick/CEP.q`
- Feedhandler process: `tick/fh.q` 

### Tickerplant (TP) - tick.q
Run the following to start the TP process:

```
q tick.q sym /home/mshaw_kx_com/Exercise_1/tplogs/ -p 5020
```
- `sym` is the name of the schema file. 
- `/home/mshaw_kx_com/Exercise_1/tplogs/` is the filepath to the directory where the TP log file will be located.
- `5020` is the port number for the TP.

Upon startup a table called `.perm.info` should be present containing:
- Any handles opened up to the TP.
- Host.
- Time of when connection is opened.

The number of messages processed by the TP will also be displayed. 

All these details will be displayed every minute.
```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ q tick.q sym /home/mshaw_kx_com/Exercise_1/tplogs/ -p 5020
KDB+ 4.0 2022.04.15 Copyright (C) 1993-2022 Kx Systems
l64/ 2(2)core 7978MB mshaw_kx_com advanced-kdb 10.154.0.3 EXPIRE 2023.12.07 dcrossey@kx.com #76201

q)"2023.01.09D14:53:59.329614000 - Number of Log Messages Processed: 0"
handle host time
----------------
```
If you are opening up a connection to the TP, you should check `.perm.info` to make sure the connection has been made. For example:

```
"2023.01.09D15:37:14.700036000 - Number of Log Messages Processed: 0"
handle host         time                         
-------------------------------------------------
6      advanced-kdb 2023.01.09D15:31:31.698713000
```

The TP log file will be `sym*today's date*` and should be present in the filepath you provide upon startup. 

### RDB's
#### rdb.q
This RDB only subscribes to the the trade and quotes table. It can be started up as follows:

```
q tick/rdb.q :5020 -p 5021
```
- `:5020` is the TP port number.
- `5021` is the rdb port number.

Both the quote and trade table should be available upon startup of the process:

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ q tick/rdb.q :5020 -p 5021
KDB+ 4.0 2022.04.15 Copyright (C) 1993-2022 Kx Systems
l64/ 2(2)core 7978MB mshaw_kx_com advanced-kdb 10.154.0.3 EXPIRE 2023.12.07 dcrossey@kx.com #76201

q)tables[]
`quote`trade
```
#### rdb_ag.q
This RDB subscribes to all tables. It can be started up as follows:

```
q tick/rdb_ag.q :5020 -p 5022
```
- `:5020` is the TP port number.
- `5022` is the rdb port number.

All tables should be available upon startup of the process:

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ q tick/rdb_ag.q :5020 -p 5022
KDB+ 4.0 2022.04.15 Copyright (C) 1993-2022 Kx Systems
l64/ 2(2)core 7978MB mshaw_kx_com advanced-kdb 10.154.0.3 EXPIRE 2023.12.07 dcrossey@kx.com #76201

q)tables[]
`aggregate`quote`trade
```
The aggregate table will only be populated if the CEP is started.
#### CEP.q
This process subscribes to trades and quote from the TP and then calculates metrics for the aggregation table and publishes the data back to the TP. It can be started up as follows:

```
q tick/CEP.q :5020 -p 5023
```
- `:5020` is the TP port number.
- `5023` is the CEP port number.

Only trade and quote tables should be available upon startup of the process:

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ q tick/CEP.q :5020 -p 5023
KDB+ 4.0 2022.04.15 Copyright (C) 1993-2022 Kx Systems
l64/ 2(2)core 7978MB mshaw_kx_com advanced-kdb 10.154.0.3 EXPIRE 2023.12.07 dcrossey@kx.com #76201

q)tables[]
`quote`trade
```
The CEP will aggregate every minute.

### Feedhandler (FH) - fh.q
The feedhandler supplies trades and quotes to the tick system. It should be started up last as follows:

```
q tick/fh.q :5020 -p 5024
```
- `:5020` is the TP port number.
- `5025` is the FH port number

The feedhandler publishes every 10 seconds but the RDB's only get updates from the TP every minute. So after starting up the feedhandler wait around a minute to see if the trade and quotes tables are populated. 

### Logging - logging.q

The logging script is loaded into each process upon startup. The script holds the functions for logOut and logError and is located in:
```
/home/mshaw_kx_com/Exercise_1/logging.q
```
Examples of the ouput can be seen below:

```
---- initialising new log file ----
2023.01.09D17:15:27.003224000 [    0.35|   64.00|   64.00|    0.00MB]user:mshaw_kx_com<>Connection Closed from advanced-kdb:656 on handle 0
```

### Startup/shutdown scripts 
#### startup.sh
To start all processes run:
```
./start.sh ALL
```
Starting all processes should read as below:
```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ./start.sh ALL
starting up all q processes
tickerplant started up
All real time subscribers started
feed handler publishing data
```
To start individual processes you can run: 
- `RDB`
- `RDB_AG`
- `CEP`
- `FH`

Upon startup a log file for each process is created. These log files can be checked to see whether the processes have started with no error. They are stored in `logdir`. A process should show the following in its logfile if started correctly:
```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ cat logdir/RDB.log
---- initialising new log file ----
2023.01.09D17:31:39.815500000 [    0.35|   64.00|   64.00|    0.00MB]user:mshaw_kx_com<>Connection Closed from advanced-kdb:941 on handle 0
```

Ports for all the processes are predefined in the script.
#### testing.sh
This script can be used to see which processes are running:

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ./testing.sh
mshaw_k+   939     1  0 17:31 pts/2    00:00:00 q /home/mshaw_kx_com/Exercise_1/tick.q sym /home/mshaw_kx_com/Exercise_1/tplogs/ -p 5020 -name TICK
mshaw_k+   941     1  0 17:31 pts/2    00:00:00 q /home/mshaw_kx_com/Exercise_1/tick/rdb.q :5020 -p 5021 -name RDB
mshaw_k+   942     1  0 17:31 pts/2    00:00:00 q /home/mshaw_kx_com/Exercise_1/tick/CEP.q :5020 -p 5023 -name CEP
mshaw_k+   943     1  0 17:31 pts/2    00:00:00 q /home/mshaw_kx_com/Exercise_1/tick/rdb_ag.q :5020 -p 5022 -name RDB_AG
mshaw_k+   951     1  0 17:31 pts/2    00:00:00 q /home/mshaw_kx_com/Exercise_1/tick/fh.q :5020 -p 5024 -name FH
```
#### shutdown.sh
This script can be used to shutdown individual scripts or all scripts. The same variables can be used as `startup.sh`. 
```
./shutdown.sh ALL
```
You can use `testing.sh` to see if the processes are still running 
### Ticker Plant log replay - LogReplay.q

This script that reads in the TP log file and creates a new tickerplant log file which only contains the trade updates for ibm.n.

Run the following to run the script:

```
q LogReplay.q -OldLog /home/mshaw_kx_com/Exercise_1/tplogs/sym2023.01.03 -NewLog /home/mshaw_kx_com/Exercise_1/tplogs/newSym2023.01.03
```
- `OldLog` is the path to the TP logfile 
- `NewLog` is the path to the updated logfile. `newSym2023.01.03` is the name of the updated logfile but you can name it whatever you want.

The new log file should be created if the script runs successfully.

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ls tplogs
newSym2023.01.09  sym2023.01.09
```
The new log file should only contain trade updates for ibm.n:
```
q)get `:/home/mshaw_kx_com/Exercise_1/tplogs/newSym2023.01.09
`upd `trade (,0D18:27:49.146598000;,`IBM.N;,191.1107;,663)
`upd `trade (,0D18:31:09.146612000;,`IBM.N;,191.0926;,256)
```

### End Of Day script - EOD.q
The end of day script can be run as follows:
```
q EOD.q -p 5030 -hdb /home/mshaw_kx_com/Exercise_1/hdb/ -logs /home/mshaw_kx_com/Exercise_1/tplogs/ -date 2023.01.09
```
- `hdb` is the filepath to the hdb.
- `logs` is the filepath to the TP logfile directory.
- `date` is the TP log file date you wish to create a partioned hdb with. This will also be the date of the date partition. 

You can check the hdb directory to see if the script ran successfully. You should expect a sym file to be created which contains a list of all the syms as well as the date partition:
```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ls hdb
2023.01.09  sym
mshaw_kx_com@advanced-kdb:~/Exercise_1$ cat hdb/sym

MSFT.OIBM.NVOD.LBA.NGS.N
```
Within the date partition all the tables should be present:
```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ls hdb/2023.01.09
aggregate  quote  trade
```
Each of those directories should contain the columns of each table as well as the .d file. Hidden file .d lists the columns in the order they appear in the table. Using the quote table as an example:

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ ls -a hdb/2023.01.09/quote
.  ..  .d  asize  ask  bid  bsize  sym  time
```

### Load CSV - loadCSV.q
This script loads in a csv file and publishes the data to the TP. Run the script as follows:
```
q loadCSV.q :5020 -p 5031 -tab trade -csv /home/mshaw_kx_com/Exercise_1/trade.csv
```
- `:5020` is the TP port number.
- `tab` name of the table you are updating.
- `csv` file path to csv file.

To check if the script pushed data to the TP you can check the table you've updated on the RDB. 

```
mshaw_kx_com@advanced-kdb:~/Exercise_1$ q tick/rdb.q :5020 -p 5021
KDB+ 4.0 2022.04.15 Copyright (C) 1993-2022 Kx Systems
l64/ 2(2)core 7978MB mshaw_kx_com advanced-kdb 10.154.0.3 EXPIRE 2023.12.07 dcrossey@kx.com #76201

q)trade //Before
time                 sym    price    size
-----------------------------------------
0D18:26:09.146583000 MSFT.O 45.15104 710 
0D18:27:49.146598000 IBM.N  191.1107 663 
0D18:29:29.146579000 VOD.L  341.3306 709 
0D18:31:09.146612000 IBM.N  191.0926 256 
q)trade //After
time                 sym    price    size
-----------------------------------------
0D18:26:09.146583000 MSFT.O 45.15104 710 
0D18:27:49.146598000 IBM.N  191.1107 663 
0D18:29:29.146579000 VOD.L  341.3306 709 
0D18:31:09.146612000 IBM.N  191.0926 256 
0D18:58:23.828369000 TSLA.A 500.1    10  
0D18:59:23.827745000 GME.B  234.56   300 
0D19:00:13.825580000 AMC.L  24.43    20  
0D19:00:43.830675000 AAPL.L 2124.24  68  
0D20:00:15.830675000 TSLA.A 498.34   160 
0D20:00:18.830675000 AMZN.A 3549.59  25  
```
### Schema Change

Adding another column would mean the sym.q file would need to be changed. An update in the feedhandler and cep would also need to be made to include this new column and potentially data for the new column. Each of the partitions and the .d files in the hdb would also need to be changed. The ideal time to do this would be outside of trading hours in a real life scenario to avoid loss of data within the realtime database. 