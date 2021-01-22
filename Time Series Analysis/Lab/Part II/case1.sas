data case1;
date = intnx( 'qtr', '1jan1955'd, _n_-1);
format date yyq.;
input inven4;
cards;
4.4
5.8
6.7
7.1
5.7
4.1
4.6
4.3
2
2.2
3.6
-2.2
-5.1
-4.9
0.1
4.1
3.8
9.9
0
6.5
10.8
4.1
2.7
-2.9
-2.7
1.5
5.7
5
7.9
6.8
7.1
4.1
5.5
5.1
8
5.6
4.5
6.1
6.7
6.1
10.6
8.6
11.6
7.6
10.9
14.6
14.5
17.4
11.7
5.8
11.5
11.7
5
10
8.9
7.1
8.3
10.2
13.3
6.2
;
run;
proc print data = case1;
id date;
run;

/* AR(1) */
proc arima data = case1 plots = all plots(unpack);
identify var = inven4 nlag = 15 alpha = 0.05 ;
run;

estimate q = 1 plot  ;
run;





proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
