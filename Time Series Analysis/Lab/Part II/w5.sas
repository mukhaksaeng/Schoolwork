
data w5;
input CDR ;
taon = intnx( 'year', '1jan1930'd, _n_-1 );
format taon year.;
t=_n_;
datalines;
100.4
105.1
109.4
110.5
116.9
118.2
122.9
126.5
125.8
130.7
131.7
131.7
134.8
136.1
137.8
142.8
144.5
144.4
150.5
152.2
155.2
157.2
157.4
161.9
165
164
168.2
170.8
169.9
169.7
173.3
173.8
175.8
177.8
179.9
180
182
184.2
187.7
187.4
186.5
188.3
190.6
190.8
196.4
199.1
203.8
205.7
215.9
216.3
219.6
219.6
222.8
226.3
230.8
235.2
235.8
241
235.9
241.4
249.6
251.4
251.4
250.2
249.5
248.7
251.1
250.1
247.6
251.3
244.2
;
run;
proc print data = w5;
id taon ;
run;


/* Model 1: RW with drift model */
proc arima data = w5 plots = all plots(unpack);
identify var = CDR nlag = 18 alpha = 0.05 stationarity = (adf);
run;

estimate p = 1 plot ;
run;

proc arima data = w5 plots = all plots(unpack);
identify var = CDR(1) nlag = 18 alpha = 0.05 stationarity = (adf)   ;
run;

estimate plot ;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ;
run;

proc print data = hula; 
run;



/*
proc reg data = w5;
model cdr = t ;
run;
*/


/* Model 2: AR(1) - WRONG */
/*
proc arima data = w5 plots = all plots(unpack);
identify var = CDR nlag = 18 alpha = 0.05;
run;

estimate p = 1 plot ;
run;
*/
