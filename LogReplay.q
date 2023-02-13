// q LogReplay.q -OldLog sym2023.01.03 -NewLog newSym2023.01.03 

system"l /home/mshaw_kx_com/Exercise_1/tick/sym.q";

args:.Q.opt .z.x; 

OldLog:`$(raze ":",args[`OldLog]);
NewLog:`$(raze ":",args[`NewLog]);

/creating new log file
.[NewLog;();:;()];
 
/opening handle to new log file
logh:hopen NewLog;
 
/getting trade data from original log file
data:get OldLog;
Index1:where (`trade=data[;1])
Index2:where (`IBM.N=raze data[Index1;2;1]);
data:data[Index1][Index2];
data:data[;2];
 
/setting IBM.N data in new logfile
{logh enlist (`upd;`trade;x)}each data;
 

exit 0
