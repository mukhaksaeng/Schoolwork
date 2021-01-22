data case14;
input t	Enrol2;
cards;
1	673
2	597
3	779
4	672
5	679
6	568
7	696
8	598
9	752
10	652
11	758
12	684
13	753
14	681
15	748
16	655
17	702
18	629
19	729
20	668
21	770
22	684
23	791
24	703
25	714
26	669
27	712
28	649
29	693
30	673
31	767
32	725
33	671
34	610
35	692
36	636
37	732
38	659
39	710
40	647
41	739
42	676
43	700
44	615
45	745
46	670
47	746
48	638
49	753
50	632
51	747
52	648
53	780
54	683
;
run;
proc print data = case14;
id t;
run;

proc arima data = case14 plots = all plots(unpack);
identify var = enrol2(2) nlag = 14 alpha = 0.05 ;
run;

estimate q = 3 plot  noint ;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
proc print data = hula;
run;

proc arima data = lead plots = all plots(unpack);
identify var = defects nlag = 12 alpha = 0.05 ;
estimate p = 2 plot  noint ;
forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;
