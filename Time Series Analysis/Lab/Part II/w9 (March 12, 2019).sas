data w9;
input zt ;
date = intnx( 'month', '1jan1971'd, _n_-1 );
format date yymon.;
t = _n_;
datalines;
707
655
638
574
552
980
926
680
597
637
660
704
758
835
747
617
554
929
815
702
640
588
669
675
610
651
605
592
527
898
839
614
594
576
672
651
714
715
672
588
567
1057
949
683
771
708
824
835
980
969
931
892
828
1350
1218
977
836
838
866
877
1007
951
906
911
812
1172
1101
900
841
853
922
886
896
936
902
765
735
1234
1052
868
798
751
820
725
821
895
851
734
636
994
990
750
727
754
792
817
856
886
833
733
657
1004
956
777
761
709
777
771
840
847
774
720
848
1240
1168
936
853
910
953
874
1026
1030
946
860
856
1190
1038
883
843
857
1016
1003
;
run;
proc print data = w9;
id date ;
run;


proc arima data = w9 plots = all plots(unpack);
identify var = zt nlag = 36 alpha = 0.05 stationarity = (adf)  ;
run;

proc arima data = w9 plots = all plots(unpack);
identify var = zt(12) nlag = 36 alpha = 0.05;
run;


/*proc arima data = w9 plots = all plots(unpack);
identify var = zt(1 12) nlag = 36 alpha = 0.05;
run;*/


estimate q = (12) p = 1 plot ;
run;


estimate q = (12) p = 2 plot ;
run;


estimate q = (12) p = 1 plot ;
run;


forecast lead = 12 alpha = 0.05
        out = hula printall ;
run;

proc print data = hula; run;





