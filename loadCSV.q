// q loadCSV.q :5020 -p 5031 -tab table -csv path/to/csv/
system"l /home/mshaw_kx_com/Exercise_1/tick/sym.q";
args:.Q.opt .z.x; 

filepath: `$(raze ":",args[`csv]);
a:(upper(0!meta `$(first args[`tab]))`t;enlist",") 0: filepath;

h:hopen `$":",.z.x 0;
 
![0N;"" sv  ("publishing ";string(count a);" records to the TP")];
neg[h](".u.upd";`$(first args[`tab]);value flip a);
neg[h][];
exit 0
