data case4;
date = intnx( 'qtr', '1jan1947'd, _n_-1);
format date yyq.;
input hpermits4;
cards;
83.3
83.2
105.3
117.7
104.6
108.8
93.9
86.1
83
102.4
119.6
141.4
158.6
161.3
158.2
136.1
121.9
97.7
103.3
92.7
106.8
102.1
110.3
114.1
109.1
105.4
97.6
100.7
102.7
110.9
120.2
131.3
138.9
130.9
123.1
110.8
108.8
103.8
97
93.2
89.7
89.9
90.2
89.6
85.8
96.9
112.7
122.7
119.8
117.4
111.9
104.7
98.3
94.9
93.3
90.9
91.9
97.2
104.7
107.7
108.2
110.7
113.2
114.6
112.2
120.2
122.1
126.6
122.3
115.9
116.9
110.1
110.4
108.9
112.1
117.6
112.2
96
78
66.9
83.5
95.8
107.7
113.7
;
run;
proc print data = case4;
id date;
run;


/* AR(3) */
proc arima data = case4 plots = all plots(unpack);
identify var = hpermits4 nlag = 24 alpha = 0.05 ;
run;


estimate p = 3  plot  ;
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
