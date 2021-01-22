data case7;
date = intnx('month', '1jan1973'd, _n_-1);
format date yymon.;
input REloans12;
cards;
46.5
47
47.5
48.3
49.1
50.1
51.1
52
53.2
53.9
54.5
55.2
55.6
55.7
56.1
56.8
57.5
58.3
58.9
59.4
59.8
60
60
60.3
60.1
59.7
59.5
59.4
59.3
59.2
59.1
59
59.3
59.5
59.5
59.5
59.7
59.7
60.5
60.7
61.3
61.4
61.8
62.4
62.4
62.9
63.2
63.4
63.9
64.5
65
65.4
66.3
67.7
69
70
71.4
72.5
73.4
74.6
75.2
75.9
76.8
77.9
79.2
80.5
82.6
84.4
85.9
87.6
;
run;
proc print data = case7;
id date;
run;


proc arima data = case7 plots = all plots(unpack);
identify var = REloans12 nlag = 18 alpha = 0.05 ;
run;


proc arima data = case7 plots = all plots(unpack);
identify var = REloans12(1 1) nlag = 18 alpha = 0.05 ;
run;

estimate q = (1) plot ;
run;

estimate q = 2 plot ;
run;

estimate q = (1) plot NOINT ;
run;


estimate p = (1) plot ;
run;



proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
