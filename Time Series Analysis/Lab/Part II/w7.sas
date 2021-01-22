data w7;
input lynx;
year = intnx( 'year', '1jan1857'd, _n_-1 );
format year year.;
datalines;
23362
31642
33757
23226
15178
7272
4448
4926
5437
16498
35971
76556
68392
37447
45686
7942
5123
7106
11250
18774
30508
42834
27345
17834
15386
9443
7599
8061
27187
51511
74050
78773
33899
18886
11520
8352
8660
12902
20331
36853
56407
39437
26761
15185
4473
5781
9117
19267
36116
58850
61478
36300
9704
3410
3774
;
run;
proc print data = w7;
id year;
run;


/* Model 1: ? model */

proc arima data = w7 plots = all plots(unpack);
identify var = lynx nlag = 14 alpha = 0.05;
run; 

estimate p = (1) plot ;
run;

estimate p = 2 plot ;
run;



/*
estimate p = 2 plot ;
run;
*/

forecast lead = 12 alpha = 0.05 
	out = hula printall ; 
run;

proc print data = hula; run;
