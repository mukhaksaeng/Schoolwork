data case15;
date = intnx( 'qtr', '1jan1958'd, _n_-1 );
format date yyq.;
input Exports4;
cards;
732.2
756.8
644.3
736
626.7
706.7
678
854.9
957
1009.3
999.9
1007.7
1050
1042.8
935.1
1124.5
1129.5
1229.3
1053.6
1161.8
1194
1254.9
1149.1
1307
1334.7
1306.7
1193.3
1433
1094.9
1351.4
1243.3
1562.5
1447
1371.7
1297.2
1388
1413.5
1444.6
1299.3
1485.1
1397.8
1553.3
;
run;
proc print data = case15;
id date;
run;

proc arima data = case15 plots = all plots(unpack);
identify var = Exports4 nlag = 12 alpha = 0.05 stationarity = (adf);
run;

proc arima data = case15 plots = all plots(unpack);
identify var = Exports4(1) nlag = 12 alpha = 0.05 stationarity = (adf);
run;

estimate q = 3;
run;

proc arima data = case15 plots = all plots(unpack);
identify var = Exports4(1 4) nlag = 12 alpha = 0.05 stationarity = (adf);
run;

estimate p = 1 q = (4);
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
proc print data = hula;
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = 2 plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
