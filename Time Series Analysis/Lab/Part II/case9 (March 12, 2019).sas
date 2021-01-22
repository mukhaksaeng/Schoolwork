data case9;
date = intnx( 'month', '1jan1969'd, _n_-1 );
format date yymon.;
input AirFlight12;
laf = log(AirFlight12);
cards;
1299
1148
1345
1363
1374
1533
1592
1687
1384
1388
1295
1489
1403
1243
1466
1434
1520
1689
1763
1834
1494
1439
1327
1554
1405
1252
1424
1517
1483
1605
1775
1840
1573
1617
1485
1710
1563
1439
1669
1651
1654
1847
1931
2034
1705
1725
1687
1842
1696
1534
1814
1796
1822
2008
2088
2230
1843
1848
1736
1826
1766
1636
1921
1882
1910
2034
2047
2195
1765
1818
1634
1818
1698
1520
1820
1689
1775
1968
2110
2241
1803
1899
1762
1901
1839
1727
1954
1991
1988
2146
2301
2338
1947
1990
1832
2066
1952
1747
2098
2057
2060
2240
2425
2515
2128
2255
2116
2315
2143
1948
1460
2344
2363
2630
2811
2972
2515
2536
2414
2545
;
run;
proc print data = case9;
id date;
run;

/* ARIMA(0,1,1)(0,1,0)s=12 theta_null = 0 */
proc arima data = case9 plots = all plots(unpack);
identify var = AirFlight12 nlag = 36 alpha = 0.05 ;
run;


proc arima data = case9 plots = all plots(unpack);
identify var = laf nlag = 36 alpha = 0.05 ;
run;


proc arima data = case9 plots = all plots(unpack);
identify var = AirFlight12(12) nlag = 36 alpha = 0.05 ;
run;


proc arima data = case9 plots = all plots(unpack);
identify var = AirFlight12(1 12) nlag = 36 alpha = 0.05 ;
run;


estimate  q = 1 plot  ;
run;

estimate  q = 1 plot noint ;
run;

/*
estimate  q = (1)(12) plot  ;
run;
*/

forecast lead = 12 alpha = 0.05 out = hula1 printall ; 
run;

proc print data = hula1;
run;


proc univariate data = hula1 normal;
var  residual;
run; 


