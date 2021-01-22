/*US Candy Production (Monthly)
SEASONAL*/
/*proc import datafile = 'C:/Users/Justin/Desktop/TIMESER PROJECT/candy_production.csv' out = temp replace;
run;*/

proc import datafile = 'C:/Users/11206438/Desktop/TIMESER PROJECT/candy_production.csv' out = temp replace;
run;

data candy_data;
set temp (rename = (observation_date = date IPG3113N = prod));
t = _n_;
run;

proc print data = candy_data;
id date;
run;

proc arima data = candy_data plots = all plots(unpack);
identify var = prod nlag = 137 alpha = 0.05 stationarity = (adf);
run;

/*decrease lags*/
proc arima data = candy_data plots = all plots(unpack);
identify var = prod nlag = 36 alpha = 0.05 stationarity = (adf);
run;

/*seasonal differencing*/
proc arima data = candy_data plots = all plots(unpack);
identify var = prod(12) nlag = 36 alpha = 0.05 stationarity = (adf);
run;

/*ordinary differencing*/
proc arima data = candy_data plots = all plots(unpack);
identify var = prod(1 12) nlag = 36 alpha = 0.05 stationarity = (adf);
run;

/*seasonal MA(1), AR(2)*/
estimate p = 2 q = (12) plot;
run;

/*seasonal MA(1), MA(5), AR(2)*/
estimate p = 2 q = (1 2 3 4 5)(12) plot;
run;

/*same as above but no constant term*/
estimate p = 2 q = (1 2 3 4 5)(12) plot noint;
run;

/*overfitting*/
estimate p = 3 q = (1 2 3 4 5)(12) plot noint;
run;

estimate p = 2 q = (1 2 3 4 5 6)(12) plot noint;
run;

estimate p = 2 q = (1 2 3 4 5)(12 24) plot noint;
run;

/*forecast*/
estimate p = 2 q = (1 2 3 4 5)(12) plot noint;
run;

forecast lead = 12 alpha = 0.05 out = candy_forecast printall ;
run;

proc print data = candy_forecast; 
run;

/* automatic model selection */
proc import datafile = 'C:/Users/11206438/Desktop/TIMESER PROJECT/candy_production.csv' out = temp replace;
run;

data candy_data;
set temp (rename = (observation_date = date IPG3113N = prod));
date = intnx( 'qtr', '1jan72'd, _n_-1);
t = _n_;
run;

proc x12 data = candy_data date = date interval = qtr;
var prod;
transform power = 0;
automdl print = unitroottest unitroottestmdl autochoicemdl best5model;
estimate;
x11;
tables;
output out = out a1 d10 d11 d12 d13;
run;
/*(3,1,1),(0,0,1)*/
proc arima data = candy_data plots = all plots(unpack);
identify var = prod(1) nlag = 36 alpha = 0.05 stationarity = (adf);
run;

estimate p = 3 q = (1)(12) plot;
run;

/* Peso-Dollar Exchange Rate from BSP
NON-SEASONAL */
proc import datafile = 'C:/Users/Justin/Desktop/TIMESER PROJECT/BSP_Exchange.csv' out = temp replace;
run;

data exchange_data;
set temp;
date = intnx('month', '1jan2004'd, _n_-1);
format date yymon.;
t = _n_;

proc print data = exchange_data;
id date;
run;

proc arima data = exchange_data plots = all plots(unpack);
identify var = exch nlag = 48 alpha = 0.05 stationarity = (adf);
run;

/*ordinary differencing*/
proc arima data = exchange_data plots = all plots(unpack);
identify var = exch(1) nlag = 48 alpha = 0.05 stationarity = (adf);
run;

/*random walk*/
estimate plot;
run;

/*same as above but no constant term*/
estimate plot noint;
run;

/*forecast*/
forecast lead = 12 alpha = 0.05 out = exch_forecast printall ;
run;

proc print data = exch_forecast; 
run;
