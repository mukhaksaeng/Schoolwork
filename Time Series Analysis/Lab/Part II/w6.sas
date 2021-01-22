data w6;
input yosi ;
taon = intnx( 'year', '1jan1871'd, _n_-1 );
format taon year.;
lyosi = log(yosi);
datalines;
327
385
382
217
609
466
621
455
472
469
426
579
509
580
611
609
469
661
525
648
747
757
767
767
745
760
703
909
870
852
886
960
976
857
939
973
886
836
1054
1142
941
1117
992
1037
1157
1207
1326
1445
1444
1509
1005
1254
1518
1245
1376
1289
1211
1373
1533
1648
1565
1018
1372
1085
1302
1163
1569
1386
1881
1460
1262
1408
1406
1951
1991
1315
2107
1980
1969
2030
2332
2256
2059
2244
2193
2176
1668
1736
1796
1944
2061
2315
2344
2228
1855
1887
1968
1710
1804
1906
1705
1749
1742
1990
2182
2137
1914
2025
1527
1786
2064
1994
1429
1728
;
run;
proc print data = w6;
id taon ;
run;


proc arima data = w6 plots = all plots(unpack);
identify var = yosi nlag = 30 alpha = 0.05
	stationarity = (adf);
run; 

title 'Using log-transformed yosi';
proc arima data = w6 plots = all plots(unpack);
identify var = lyosi nlag = 30 alpha = 0.05
	stationarity = (adf);
run; 

/* Model 1: ARIMA(0,1,1) model; Wt = ln(yosi) */
proc arima data = w6 plots = all plots(unpack);
identify var = lyosi(1) nlag = 30 alpha = 0.05
	stationarity = (adf);
run; 

estimate q = 1 plot ;
run;

estimate q = 2 plot ;
run;


forecast lead = 12 alpha = 0.05 
	out = hula printall ; 
run;

proc print data = hula; run;

