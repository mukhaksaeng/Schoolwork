data case11;
date = intnx( 'month', '1jan1966'd, _n_-1 );
format date yymon.;
input Robberies12;
lnrob = Log(Robberies12);
cards;
41
39
50
40
43
38
44
35
39
35
29
49
50
59
63
32
39
47
53
60
57
52
70
90
74
62
85
84
94
70
108
139
120
97
126
149
158
124
140
109
114
77
120
133
110
92
97
78
99
107
112
90
98
125
155
190
236
189
174
178
136
161
171
149
184
155
276
224
213
279
268
287
238
213
257
293
212
246
353
339
308
247
257
322
298
273
312
249
286
279
309
401
309
328
353
354
327
324
285
243
241
287
355
460
364
487
452
391
500
451
375
372
302
316
398
394
431
431
;
run;
proc print data = case11;
id date;
run;


proc arima data = case11 plots = all plots(unpack);
identify var = Robberies12 nlag = 36 alpha = 0.05 stationarity = (adf);
run;


proc arima data = case11 plots = all plots(unpack);
identify var = lnrob nlag = 36 alpha = 0.05 stationarity = (adf);
run;



proc arima data = case11 plots = all plots(unpack);
identify var = lnrob(1) nlag = 36 alpha = 0.05 stationarity = (adf);
run;

/*
estimate q = 1 plot ;
run;

estimate p = (12) q = 1 plot ;
run;

estimate q = (1)(12) plot ;
run;
*/

estimate p = (12) q = (1)(12) plot ;
run;

estimate p = (12) q = (1)(12) plot noint;
run;

estimate p = (1 2)(12) q = (12) plot noint;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
