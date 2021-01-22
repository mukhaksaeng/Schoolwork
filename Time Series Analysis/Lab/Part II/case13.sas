data case13;
date = intnx( 'month', '1jan1969'd, _n_-1 );
format date yymon.;
input Cigar12;
cards;
484
498
537
552
597
576
544
621
604
719
599
414
502
494
527
544
631
557
540
588
593
653
582
495
510
506
557
559
571
564
497
552
559
597
616
418
452
460
541
460
592
475
442
563
485
562
520
346
466
403
465
485
507
483
403
506
442
576
480
339
418
380
405
452
403
379
399
464
443
533
416
314
351
354
372
394
397
417
347
371
389
448
349
286
317
288
364
337
342
377
315
356
354
388
340
264
;
run;
proc print data = case13;
id date;
run;

proc arima data = case13 plots = all plots(unpack);
identify var = Cigar12 nlag = 24 alpha = 0.05 stationarity = (adf);
run;

proc arima data = case13 plots = all plots(unpack);
identify var = Cigar12(1) nlag = 24 alpha = 0.05 stationarity = (adf);
run;

proc arima data = case13 plots = all plots(unpack);
identify var = Cigar12(1 12) nlag = 24 alpha = 0.05 stationarity = (adf);
run;

/*
estimate p = (1 2) q = (3)(12) plot;
run;
*/

estimate p = (1 2) q = (12) plot;
run;

estimate p = (12) q = (1)(12) plot;
run;

estimate q = (1)(12) plot;
run;

estimate p = (12) q = 1 plot;
run;

estimate q = (1)(12) plot;
run;

forecast lead = 12 alpha = 0.05 out = hula printall ; 
run;

proc print data = hula;
run;
