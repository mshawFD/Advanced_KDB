system"l /home/mshaw_kx_com/Exercise_1/tick/u.q";
system"l /home/mshaw_kx_com/Exercise_1/logging.q";

/Checking Operating System is windows
if[not "w"=first string .z.o;system "sleep 1"];

/a simple insert as the ups function (Vanilla RTS)
upd:{[t;d] if[t in `quote`trade; t insert d]};
/opening handle to TP
h: hopen `$":",.z.x 0;

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;
        t@:where `g=attr each t@\:`sym;
        .Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
        @[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;
        if[null first y;:()];
        -11!y;
	system "cd ",1_-10_string first reverse y};
		
/subscribe to trade and quotes tables
//.u.rep .(h)"({.u.sub[x;`]}each `trade`quote;`.u `i`L)";

(.[;();:;].)each h"({.u.sub[x;`]}each `trade`quote)";
if[null first h"(`.u `i`L)";:()];
-11!h".u.L";

.agg.Trade:{select minPrice:min price, maxPrice:max price, tradedVol:count i by sym from trade};


.agg.Quote:{select maxBid:max bid,minBid:min bid, maxAsk:max ask, minAsk:min ask by sym from quote};

.agg.firstTrade:.agg.Trade[];
.agg.firstQuote:.agg.Quote[];

.z.ts:{ .agg.firstTrade: .agg.firstTrade, .agg.Trade[];
	.agg.firstTrade: select minPrice:min minPrice, maxPrice:max maxPrice, tradedVol:sum tradedVol by sym from .agg.firstTrade;
	.agg.firstQuote: .agg.firstQuote, .agg.Quote[];
	.agg.firstQuote: select maxBid: max maxBid, minBid: min minBid, maxAsk: max maxAsk, minAsk: min minAsk by sym from .agg.firstQuote;
        toPub:0!(update time:.z.N from .agg.firstQuote lj .agg.firstTrade);

	neg[h](".u.upd";`aggregate; value exec time,sym,maxBid,minBid,maxAsk,minAsk,minPrice,maxPrice,tradedVol from toPub);
	delete from `quote;
	delete from `trade;
	
	  }

\t 60000
