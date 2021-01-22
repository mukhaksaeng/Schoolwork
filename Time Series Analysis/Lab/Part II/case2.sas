data case2;
date = intnx( 'qtr', '1jan1955'd, _n_-1);
format date yyq.;
input savings4;
cards;
4.9
5.2
5.7
5.7
6.2
6.7
6.9
7.1
6.6
7
6.9
6.4
6.6
6.4
7
7.3
6
6.3
4.8
5.3
5.4
4.7
4.9
4.4
5.1
5.3
6
5.9
5.9
5.6
5.3
4.5
4.7
4.6
4.3
5
5.2
6.2
5.8
6.7
5.7
6.1
7.2
6.5
6.1
6.3
6.4
7
7.6
7.2
7.5
7.8
7.2
7.5
5.6
5.7
4.9
5.1
6.2
6
6.1
7.5
7.8
8
8
8.1
7.6
7.1
6.6
5.6
5.9
6.6
6.8
7.8
7.9
8.7
7.7
7.3
6.7
7.5
6.4
9.7
7.5
7.1
6.4
6
5.7
5
4.2
5.1
5.4
5.1
5.3
5
4.8
4.7
5
5.4
4.3
3.5
;
run;
proc print data = case2;
id date;
run;

/* AR(1) */
proc arima data = case2 plots = all plots(unpack);
identify var = savings4 nlag = 25 alpha = 0.05 ;
run;

estimate p = (1) plot ;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
