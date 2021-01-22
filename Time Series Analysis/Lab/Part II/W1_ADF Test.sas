
data w1;
input defects;
date = intnx( 'year', '1jan1930'd, _n_-1 );
format date year.;
cards;
1.2
1.5
1.54
2.7
1.95
2.4
3.44
2.83
1.76
2
2.09
1.89
1.8
1.25
1.58
2.25
2.5
1.05
1.46
1.54
1.42
1.57
1.4
1.51
1.08
1.27
1.18
1.39
1.42
2.08
1.85
1.82
2.07
2.32
1.23
2.91
1.77
1.61
1.25
1.15
1.37
1.79
1.68
1.78
1.84
;
run;

proc print data = w1;
var defects;
id date ;
run;


proc gplot data = w1;
plot defects*date;
symbol i = join v = diamond ;
run;


proc arima data = w1 plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 
 	STATIONARITY = (adf);
run;

 
estimate p = (1) plot ;
run;


forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;


