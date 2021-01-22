
data case6;
input week ATT52;
datalines;
1	61
2	61.625
3	61
4	64
5	63.75
6	63.375
7	63.875
8	61.875
9	61.5
10	61.625
11	62.125
12	61.625
13	61
14	61.875
15	61.625
16	59.625
17	58.75
18	58.75
19	58.25
20	58.5
21	57.75
22	57.125
23	57.75
24	58.875
25	58
26	57.875
27	58
28	57.125
29	57.25
30	57.375
31	57.125
32	57.5
33	58.375
34	58.125
35	56.625
36	56.25
37	56.25
38	55.125
39	55
40	55.125
41	53
42	52.375
43	52.875
44	53.5
45	53.375
46	53.375
47	53.5
48	53.75
49	54
50	53.125
51	51.875
52	52.25
;
run;
proc print data = case6;
id week;
run;

proc arima data = case6 plots = all plots(unpack);
identify var = att52 nlag = 13 alpha = 0.05 ;
estimate p = (1) plot  ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
