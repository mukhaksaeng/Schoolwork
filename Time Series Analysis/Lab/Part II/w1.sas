data w1;
input Defects;
t = _n_; /*automatically creates time column*/
datalines;
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
id t; /*use t as identifier*/
run;


/* Model 1: AR(1) model */

proc arima data = w1 plots = all plots(unpack);  /*Plot everything (all) and separately (unpack)*/
identify var = defects nlag = 12 alpha = 0.05; /* number of lags is 1/4 of the sample size. Beyond this number of lags, ACF & PACF will be artificial.*/
run; 

estimate p = 1 plot ; 
run;

/* OTHER MODELS:
estimate p = (1) plot ; (Uses latest time series submitted with 'identify')
run;

estimate q = 1 plot ; (MA(1) model)
run;

estimate p = (1 3) plot ; (Fits only lags 1 and 3 (non-hierarchical model) vs. p = 3 which fits all lags up to 3 (hierarchical model))
run;
*/

forecast lead = 12 alpha = 0.05 out = hula printall; /* lead = 12 -> forecast next 12 periods */ 
run;

proc print data = hula;
run;

proc univariate data = hula normal plot ;
var residual;
run;

proc arima data = w1 plots = all plots(unpack); 
identify var = defects nlag = 12 alpha = 0.05;
run; 

/* overfitting - AR(2) model */
estimate p = 2 plot ; 
run;
