system"l /home/mshaw_kx_com/Exercise_1/logging.q"

if[not "w"=first string .z.o;system "sleep 1"];

upd:{[t;d] if[t in `quote`trade; t insert d]};

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;
        t@:where `g=attr each t@\:`sym;
        .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
        @[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;
	if[null first y;:()];
	-11!y;
	system "cd ",1_-10_string first reverse b};
	
/.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`]each `trade`quote;`.u `i`L)";
h: hopen `$":",.z.x 0;
(.[;();:;].)each h"({.u.sub[x;`]}each `trade`quote)";
if[null first h"(`.u `i`L)";:()];
-11!h".u.L"; 
