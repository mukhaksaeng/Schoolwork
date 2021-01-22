data w3;
input blowfly;
t = _n_;
datalines;
1676
3075
3815
4639
4424
2784
5860
5781
4897
3920
3835
3618
3050
3772
3517
3350
3018
2625
2412
2221
2619
3203
2706
2717
2175
1628
2388
3677
3156
4272
3771
4955
5584
3891
3501
4436
4369
3394
3869
2922
1843
2837
4690
5119
5838
5389
4993
4446
4651
4243
4620
4849
3664
3016
2881
3821
4300
4168
5448
5477
8579
7533
6884
4127
5546
6316
6650
6304
4842
4352
3215
2652
2330
3123
3955
4494
4780
5753
5555
5712
4786
4066
;
run;
proc print data = w3;
run;


/* Model 1: AR(1) model */
proc arima data = w3 plots = all plots(unpack);
identify var = blowfly nlag = 21 alpha = 0.05 stationarity = (adf); /* 0.25(82) = 20.5. Thus, we use 21 lags */
run; 

estimate p = 1 plot ;
run;

/* overfitting: AR(2) model */
estimate p = 2 plot ;
run;


forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;

proc print data = hula; 
run;
