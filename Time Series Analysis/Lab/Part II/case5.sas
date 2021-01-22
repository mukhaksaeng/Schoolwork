data case5;
date = intnx('qtr', '1jan1965'd, _n_-1);
format date yyq.;
input RailFrt4;
cards;
166.8
172.8
178.3
180.3
182.6
184.2
188.9
184.4
181.7
178.5
177.6
181
186.5
185.7
186.4
186.3
189.3
190.6
191.7
196.1
189.3
192.6
192.1
189.4
189.7
191.9
182
175.7
192
192.8
193.3
200.2
208.8
211.4
214.4
216.3
221.8
217.1
214
202.4
191.7
183.9
185.2
194.5
195.8
198
200.9
199
200.6
209.5
208.4
206.7
193.3
197.3
213.7
225.1
;
run;
proc print data = case5;
id date;
run;

proc arima data = case5 plots = all plots(unpack);
identify var = railfrt4 nlag = 16 alpha = 0.05 ;
run;


proc arima data = case5 plots = all plots(unpack);
identify var = railfrt4(1) nlag = 16 alpha = 0.05 ;
run;


estimate q = (1) plot   ;
run;

estimate p = (1) q = (1) plot   ;
run;


estimate q = (1) plot noint ;
run;




proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
