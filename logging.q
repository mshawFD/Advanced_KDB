\d .log

str:{$[10=abs type x;(::);string]x};

details:{string[.z.p],(,[;"MB]"]" [","|" sv .Q.fmt[8;2]each 4#value .Q.w[]%2 xexp 20),"user:",string[.z.u],"<>"};

logOut:{[x](neg 1)@ details[],str x};
logErr:{[x](neg 2)@ details[],str x};

\d .

.z.po:{.log.logOut"Connection Opened from ",(":"sv string(.z.h;.z.i))," on handle ",string x};
.z.pc:{.log.logOut"Connection Closed from ",(":"sv string(.z.h;.z.i))," on handle ",string x}
