data case10;
date = intnx( 'qtr', '1jan1953'd, _n_-1 );
format date yyq.;
input Profit4;
cards;
4.4
4.3
4.4
4
4.3
4.6
4.5
4.7
5.2
5.4
5.5
5.6
5.4
5.4
5
5.1
5.3
4.9
4.7
4.3
3.6
3.7
4.4
4.8
5
5.3
4.6
4.4
5
4.4
4.3
3.9
3.8
4.2
4.4
4.7
4.6
4.4
4.5
4.7
4.4
4.7
5.7
5
5.1
5.2
5.3
5.3
5.6
5.5
5.6
5.6
5.8
5.7
5.6
5.4
5
5
4.9
5.1
5.1
5
5.1
5.1
5.1
4.9
4.8
4.5
4.1
4.2
4
3.6
4
4.2
4.2
4.1
4.2
4.2
4.3
4.5
;
run;
proc print data = case10;
id date;
run;

proc arima data = case10 plots = all plots(unpack);
identify var = Profit4 nlag = 20 alpha = 0.05 stationarity = (adf);
run;

estimate p = 1 plot ;
run;

/*
estimate p = (1) q = (4)  plot ;
run;
*/

proc arima data = case10 plots = all plots(unpack);
identify var = Profit4(1) nlag = 20 alpha = 0.05 stationarity = (adf);
run;

estimate plot ;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
