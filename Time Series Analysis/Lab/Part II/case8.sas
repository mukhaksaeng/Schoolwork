data case8;
input t	Parts52;
cards;
1	80.4
2	83.9
3	82.6
4	77.9
5	83.5
6	80.8
7	78.5
8	79.3
9	81.2
10	81.1
11	78.2
12	80.9
13	77.9
14	81.5
15	81.4
16	78.9
17	76.2
18	79.4
19	81.4
20	80
21	79.9
22	80.5
23	79.7
24	81.4
25	82.4
26	83.1
27	80.4
28	82.9
29	82.7
30	84.9
31	84.4
32	83.7
33	84.5
34	84.6
35	85.2
36	85.2
37	80.1
38	86.5
39	81.8
40	84.4
41	84.2
42	84.1
43	83.2
44	83.9
45	86
46	82.2
47	81.2
48	83.7
49	82.7
50	84.8
51	81.2
52	83.8
53	86.4
54	81.6
55	83.6
56	85.9
57	79.8
58	80.8
59	78.7
60	80.6
61	79.4
62	77.9
63	80.4
64	79.4
65	83.2
66	81
67	81.7
68	81.2
69	79.1
70	80
71	81.5
72	83.8
73	82.2
74	82.4
75	79.9
76	82.3
77	83.2
78	81.3
79	82.4
80	82.2
81	82
82	83.7
83	84.6
84	85.7
85	85.1
86	84.5
87	85.6
88	84.7
89	79.9
90	88.9
;
run;
proc print data = case8;
id t;
run;

proc arima data = case8 plots = all plots(unpack);
identify var = Parts52 nlag = 25 alpha = 0.05 stationarity = (adf);
run;

estimate p = 3 plot;
run;

proc arima data = case8 plots = all plots(unpack);
identify var = Parts52(1) nlag = 25 alpha = 0.05 stationarity = (adf);
run;

estimate q = 1 plot;
run;

estimate q = 1 plot noint;
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = (1) plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
