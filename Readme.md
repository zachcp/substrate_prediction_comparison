Antismash 4 vs Antismash 5 Predictions
================

## Executive Summary

There are differences in Adenylation domain substrate predictions
between AS4 and AS5 due to the different programs used for substrate
identification. Using the two common measures of substrate prediction,
Stachelhaus and NRPSPredictor (2/3) we can see that most of the
differences between the two programs are due to instances where one of
the programs does not generate a call. This suggests that the
differences may simply be due to different acceptance thresholds between
AS4 and AS5. However, there is also a small percentage of sequences that
are predicted to be different substrates altogether which is potentially
a concern if you are working with these clusters contianing this type of
domain..

## Intro

I’ve been watching the Antismash team develop version 5 [on
github](https://github.com/antismash/antismash) and have been very
impressed with the refactoring process. There seem to be major upgrades
across the board - in the front end HTML (more interactivity, new
cluster rule features, changed tabbed layout for clusterblast and
substrate predictions); in the refactoring of the code itself
(modularized, type hints, new `Record` handling), as well as the
Dockerfile (more data required outside of the application which will
allow smaller images and sideloading/reuse of large datasets). Really
its quite an update - big kudos the whole team and Kblin and SJShaw in
particular.

Clearly I’m a big fan so I decided to kick the tires. After exploring
for a bit I noticed that a few of the Adenylation domain substrates for
clusters that I have worked on are not being called identical in
Antismash 4 (AS4) and Antismash 5 (AS5). I wondered how prevalent this
problem was so I took a reasonably large public dataset and ran AS4 and
AS5 on them and compared the predictions between them. AS4 used to offer
a larger number of prediction programs while AS5 has narrowed donw to 1
(or 2 depending on how you count). While the AS5 approach has its
benefits in the form of speed/efficiency, I wonder if the more limited
substrate predictions of AS5 might cause us to mis or mis-predict
certain substrates.

## My Approach

1.  Download Mibig GBKS and convert to fasta
2.  Download AS4 and AS5 docker images
3.  Download AS5 sample data
4.  Run AS4 and AS5 on each of the gbks in Mibig
5.  Parse the results from the output GBK (AS4) or JSON (AS5) files.
6.  Explore the results here.

You can reproduce the data here although the domain files are availalbe
in the `output/` directory.

``` bash
# get Mibig and run against AS4 and AS5 using their docker image
#
# there are some software deps I use you may need
# parallel, docker, biopython
make download
make runsmash
output/domains_as4.txt
```

## The Data

![](images/as4_as5.png)

The substrate information for AS4 and AS5 differs. We can parse this
information out of the AS4 gbk files and the AS5 json files. As you can
see in the image above AS4 contains specificity predictions for
Stachelhaus, NRPSpredictor3, and a few other programs. AS4 has
NRPSPredictor2 outputs as well as the stachelhaus prediction. I
retrieved data from the fields in red in order looked for AS4
Stachelhaus \<—\> AS5 Stachelhaus differences as well as NRPSPredictor2
\<—\> NRPSPredictor3 SVM.

My parser scripts are in `scripts` and after pulling out the data and
renaming a few columns, I join the AS4 and AS5 data togther to create
the final analysis. To compare the substrate predictions I performed the
following checks of equality.

``` r
# compare stachelhuas calls directly
all_data$compare_stach1 <- 
  as.logical(purrr::map2(all_data$stachelhaus_predictions_4, all_data$stachelhaus_predictions_5,
             ~.x == .y))

# use grep to compare any of the substrates predicted in AS4 against AS5
# example: grepl("leu|d-leu", "leu) -> TRUE
all_data$compare_stach2 <- 
  as.logical(purrr::map2(all_data$stachelhaus_predictions_4, all_data$stachelhaus_predictions_5,
                                    ~grepl(.x, .y)))

# compare the nrpspredictor calls directly
all_data$compare_nrpspred <- 
  as.logical(purrr::map2(all_data$nrpspredictor2_single, all_data$nrpspredictor3_svm_single,
                                                  ~.x == .y))
```

The data including the equality checks are now all in a single table
with one row for each domain. There are 2988 Adenylation domains in this
dataset. It looks like this:

    ## # A tibble: 6 x 13
    ##   mibig AD_domain_idx.x AD_domain_id nrpspredictor3_… stachelhaus_pre…
    ##   <chr>           <int> <chr>        <chr>            <chr>           
    ## 1 BGC0…               0 nrpspksdoma… ala              no_call         
    ## 2 BGC0…               0 nrpspksdoma… N/A              no_call         
    ## 3 BGC0…               0 nrpspksdoma… N/A              no_call         
    ## 4 BGC0…               2 nrpspksdoma… N/A              no_call         
    ## 5 BGC0…               1 nrpspksdoma… N/A              no_call         
    ## 6 BGC0…               0 nrpspksdoma… N/A              no_call         
    ## # … with 8 more variables: AD_domain_idx.y <int>,
    ## #   nrpspredictor2_single <chr>, physicochemical_class <chr>,
    ## #   stachelhaus_predictions_5 <chr>, n <int>, compare_stach1 <lgl>,
    ## #   compare_stach2 <lgl>, compare_nrpspred <lgl>

## Stachelhaus Findings

**Are AS4 Stachelhaus values identical to AS5 Stachelhaus values?**

    ## 
    ## FALSE  TRUE 
    ##  1903   897

**Are AS4 Stachelhaus values identical to AS5 Stachelhaus values?** (use
grep to match multiple AS4 values to a single AS5 value)

    ## 
    ## FALSE  TRUE 
    ##  1320  1598

**What are the non-matching values?**

What are the twenty most common AS4 values when AS4 and AS5 do not
match? Most are `no-call`s where AS4 didn’t predict a value.

    ## .
    ##         no_call             val             ala             dpg 
    ##             907              26              25              18 
    ##             lys boh-d-leu|d-leu             dab             leu 
    ##              17              15              14              14 
    ##         gln|ser            horn             orn             trp 
    ##              12              10              10              10 
    ##         ala|gly             glu    cysa|dab|dpr  horn|nme-fhorn 
    ##               9               9               8               8 
    ##   pip|piperazic           b-ala         ile|val             thr 
    ##               8               7               7               7

What are the twenty most common AS5 values when AS4 and AS5 do not
match? (Most are `no-call`s where AS4 didn’t predict a value.

with `as4 no_calls`

    ## .
    ##   phe   leu   gln   val   pro   ala   ser   glu   orn   arg   pip   gly 
    ##   147    84    79    78    74    59    56    51    44    36    33    30 
    ##   trp   cys   ile   tyr   asn   asp   lys lys-b 
    ##    29    28    27    24    23    23    23    22

without `as4 no_calls`

    ## .
    ##      phe      gln      val      glu      orn     dhpg      ser      leu 
    ##       60       38       35       23       17       16       15       14 
    ##    lys-b d-lyserg      pro      trp      ile      cys    ala-b      arg 
    ##       14       10       10       10        9        8        7        7 
    ##      asp      gly      ala    haorn 
    ##        7        7        6        6

**What were the AS4 Values that change to Phe in AS5?**

There are 60 Phe differences. What are the AS4 calls when `AS5="phe"`?
Many hydrophobic residues to Phe. A few charged residue predicitons
where you might not expect a change.

    ## .
    ##        boh-d-leu|d-leu                    val                    leu 
    ##                     11                      9                      6 
    ##            3oh-gln|thr                    trp                    kyn 
    ##                      5                      5                      4 
    ##    boh-d-leu|d-leu|leu              33p-l-ala   3oh-gln|athr|ser|thr 
    ##                      3                      2                      2 
    ##                   horn                    tyr 4-5-dehydro-arg|me-tyr 
    ##                      2                      2                      1 
    ##               athr|ser                    bmt            boh-ome-tyr 
    ##                      1                      1                      1 
    ##              d-ser|ser                    dab                  fhorn 
    ##                      1                      1                      1 
    ##        gln|ile|ser|val          pip|piperazic 
    ##                      1                      1

## NRPS Predictor Findings

**Are AS4 NRPSPredictor3 values identical to AS5 NRPSPredictor2
values?**

There is 80% concordance between V2 and V3. Most of the differences are
due to N/A values. This brings concordnace to \>90% if we include only
those cases where a call is made.

    ## 
    ## FALSE  TRUE 
    ##   551  2249

What are the NRPSPredictor2 values when there is a discrepancy?

    ## .
    ##  N/A  pro  ala  tyr  val  dhb  leu  phe  asn  orn  asp  thr  cys  glu  ile 
    ##  324   32   24   24   21   17   17   13    9    9    8    8    7    7    7 
    ##  ser  hpg  gly dhpg  gln 
    ##    7    6    3    2    2

What are the NRPSPredictor3 values when there is a discrepancy?

    ## .
    ## N/A leu ala trp val gln phe asp lys glu thr pro tyr hpg pip ser arg gly 
    ## 164  95  32  29  29  28  24  21  20  16  15  14  12  10  10   9   8   5 
    ## asn bht 
    ##   3   2
