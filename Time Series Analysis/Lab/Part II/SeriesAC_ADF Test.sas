
data seriesAC;
input Zt t;
cards;
779	1
920	2
848	3
839	4
879	5
726	6
788	7
813	8
745	9
732	10
809	11
786	12
849	13
926	14
867	15
828	16
778	17
862	18
830	19
924	20
682	21
754	22
828	23
818	24
922	25
929	26
903	27
820	28
871	29
926	30
811	31
901	32
867	33
948	34
820	35
893	36
859	37
909	38
860	39
993	40
858	41
887	42
823	43
909	44
837	45
821	46
916	47
911	48
;
run;

proc print data = seriesAC;
var Zt;
id t ;
run;


proc gplot data = seriesAC;
plot Zt*t;
symbol i = join v = diamond ;
run;


proc arima data = seriesAC plots = all plots(unpack);
identify var = Zt nlag = 12 alpha = 0.05 
 	STATIONARITY = (adf);
run;

 	STATIONARITY = (RW);
 	STATIONARITY = (ADF);
 	STATIONARITY = (PP);


estimate  plot ;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;




