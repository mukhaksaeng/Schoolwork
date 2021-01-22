data case12;
date = intnx( 'month', '1jan1968'd, _n_-1 );
format date yymon.;
input Mtool12;
cards;
10285
11490
13975
10590
12130
12760
10005
8895
11555
10775
10355
13015
8645
9770
10530
10110
9845
12220
8385
7405
10840
10460
9220
11815
9385
8735
9820
8305
9710
10060
7490
6215
8335
7095
5580
8560
5765
5940
6485
7175
5255
6075
4530
4090
5890
4790
4170
7065
3960
4640
5675
4955
5715
7005
4780
4845
7625
6385
6620
9240
6615
7440
9880
7630
10060
10290
7265
7690
9575
9845
8635
12450
8410
9585
12930
12300
11990
12575
10500
8935
15135
12905
12890
16430
;
run;
proc print data = case12;
id date;
run;

proc arima data = case12 plots = all plots(unpack);
identify var = Mtool12(1,12) nlag = 24 alpha = 0.05 ;
run;
estimate q = (1)(12) noint plot  ;
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
