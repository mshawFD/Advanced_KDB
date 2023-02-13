system"l /home/mshaw_kx_com/Exercise_1/logging.q"

/Checking Operating System is windows
if[not "w"=first string .z.o;system "sleep 1"];


/a simple insert as the ups function (Vanilla RTS)
upd:{[t;d] if[t~`aggregate;delete from t;t insert d]};

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;
        t@:where `g=attr each t@\:`sym;
        .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
        @[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each enlist x;if[null first y;:()];-11!y};


/ Open connection to the TP and subscribe to the relevant schemas
/.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`aggregate;`];`.u `i`L)";


h: hopen `$":",.z.x 0;
(.[;();:;].)each enlist h"(.u.sub[`aggregate;`])";
if[null first h"(`.u `i`L)";:()];
-11!h".u.L";
