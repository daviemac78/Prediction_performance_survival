Performance assessment of survival prediction models
================

-   [Goals](#goals)
-   [Install/load packages and import
    data](#installload-packages-and-import-data)
    -   [Data preparation](#data-preparation)
-   [Goal 1: Assessing performance of a developed survival model in a
    new
    data](#goal-1-assessing-performance-of-a-developed-survival-model-in-a-new-data)
    -   [1.1 Calculate the absolute risk prediction at 5 years in the
        validation
        data](#11-calculate-the-absolute-risk-prediction-at-5-years-in-the-validation-data)
    -   [1.2 Discrimination measures](#12-discrimination-measures)
    -   [1.3 Calibration](#13-calibration)
        -   [1.3.1 Mean calibration - fixed time
            point](#131-mean-calibration---fixed-time-point)
        -   [1.3.2 Weak calibration - fixed time
            point](#132-weak-calibration---fixed-time-point)
        -   [1.3.3 Moderate calibration - fixed time
            point](#133-moderate-calibration---fixed-time-point)
        -   [1.3.4 Calibration when only coefficients of the model are
            available](#134-calibration-when-only-coefficients-of-the-model-are-available)
    -   [1.4 Overall performance
        measures](#14-overall-performance-measures)
-   [2. Clinical utility](#2-clinical-utility)
-   [Reproducibility ticket](#reproducibility-ticket)

## Goals

When a risk prediction model has been developed and published in the
literature, individual data are probably not available. In this
document, we assume the common scenario that a risk prediction model was
already developed and it is available in the literature. We assume that
the author(s) developed a risk prediction model using a Cox proportional
hazard regression providing the model equation in terms of coefficients
and the baseline survival at a fixed time horizon *t* (e.g. five years).

In summary the goals here are:  
+ Goal 1: to assess the prediction performance of a published risk model
with a time-to-event outcome in a new independent (external) data;  
+ Goal 2: to assess the potential clinical utility of a risk prediction
model with time-to-event outcome in the new data;

## Install/load packages and import data

First of all, install the R packages essential for the analyses. We
following libraries are needed to achieve the following goals, if you
have not them installed, please use install.packages(’‘)
(e.g. install.packages(’survival’)) or use the user-friendly approach if
you are using RStudio.

### Data preparation

Outcome and predictors in the new data must be coded as provided in the
model equation of the developed model. The time-to-death outcome should
be in years and the variables should be categorized exactly as in the
developed model.

In the prediction model developed using the Rotterdam data, violation of
proportional hazards was detected for some predictors and the
development data was administratively censored at 5 years. For this
reason, we also administratively censor patients in the new (validation)
data at 5 years.

## Goal 1: Assessing performance of a developed survival model in a new data

The performance of a risk prediction models may be evaluated through:

-   discrimination: the ability of the model to identify patients with
    and without the outcome and it requires the coefficients (or the log
    of the hazard ratios) of the developed risk prediction model to be
    evaluated;

-   calibration: the agreement between observed and predicted
    probabilities. It requires the baseline (cumulative) hazard or
    survival;

-   overall performance measures: as a combination of discrimination and
    calibration.

Unfortunately, a few publications report the complete baseline
(cumulative) hazard or survival or even the baseline (cumulative) hazard
or survival at fixed time horizon *t*.  
It is common that physicians focus on one or more clinically relevant
time horizons to inform subjects about their risk. We aim to assess the
prediction performance of a risk prediction model with time-to-event
outcome in a new data when information at a fixed time horizon(s) (here
at 5 years) of a developed prediction model were provided. The
coefficients of the model(s) are essential to assess the overall
performances and to calculate the discrimination ability of the
developed model in a new data. Information of the baseline
hazard/survival over the follow-up time or at a fixed time horizon *t*
are needed for calibration assessment.  
When the baseline is not available (and it is not uncommon in the
literature), only a graphical representation of the calibration is
possible. We assume here to know the coefficients *and the baseline
survival at 5 years *S*<sub>0</sub>*(t = 5)\* of the developed
prediction model. We also provide the graphical visualization of the
calibration when the baseline is not reported in the literature.

If the model equation is provided including the coefficients and the
baseline at fixed time point *t* (e.g. 5 years), we could validate the
risk prediction model in our external data. Typically, the model
equation is provided in terms of predicted survival at a fixed time
point *t*.

<img src="https://render.githubusercontent.com/render/math?math=%5Clarge%7B%5Csf%7BS(t)%20%3D%20S_0(t)%5E%7Bexp(%5Cbeta_1X_1%2B%5Cbeta_2X_2%2B%5Cbeta_3X_3%2B%5Ccdots%2B%5Cbeta_pX_p)%7D%7D%3DS_0(t)%5E%7Bexp(PI)%7D%7D">

where:  
*S(t)* is the survival at time *t*.  
*S*<sub>0</sub>*(t)* is the baseline survival at time *t*.  
<img src="https://render.githubusercontent.com/render/math?math=%5Csf%7BPI%20%3D%20%5Cbeta_1X_1%2B%5Ccdots%2B%5Cbeta_pX_p%7D">
is the predictor index: the combination of the coefficients estimated by
the statistical model (i.e Cox model) and the predictors.  

In some software, the baseline survival might be already internally
rescaled including the centercept. For example, the function
`rms::cph()` in the `rms` R package provides the centercept to be
included in the model equation (see formula below and
`rms::cph()$center`). More information can be found in `help(cph)` . In
`survival` package the baseline survival can be obtained using
`survival::basehaz()` then `exp(-survival::basehaz()$hazard)` to
calculate *S*<sub>0</sub>*(t)* . For details see `help(basehaz)`,
especially the argument `centered`. If the centercept is mentioned in
the model equation, this can be used to rescaled the baseline using some
easy algebraic steps.

<img src="https://render.githubusercontent.com/render/math?math=%5Clarge%7BS(t)%20%3D%20%7BS_%7B0%7D(t)%7D%5E%7Bexp(PI-c)%7D%20%3D%20%5B%7BS_%7B0%7D(t)%7D%5E%7Bexp(-c)%7D%5D%5E%7Bexp(PI)%7D%20%3D%7BS_%7B0%7D(t)_%7Bresc%7D%7D%5E%7Bexp(PI)%7D%7D">

### 1.1 Calculate the absolute risk prediction at 5 years in the validation data

This part must be run. Then, the user can also focus on one prediction
performance is interested in (e.g. discrimination).

### 1.2 Discrimination measures

Discrimination is the ability to differentiate between subjects who have
the outcome and subjects who do not. Concordance can be assessed over
several different time intervals:

-   the entire range of the data. Two concordance measures are
    suggested:

    -   Harrell’s C quantifies the degree of concordance as the
        proportion of such pairs where the patient with a longer
        survival time has better predicted survival;

    -   Uno’s C uses a time dependent weighting that more fully adjusts
        for censoring;

-   a 5 year window corresponding to our target assessment point. Uno’s
    time-dependent Area Under the Curve (AUC) is suggested. Uno’s
    time-dependent AUC summarizes discrimination at specific fixed time
    points. At any time point of interest, *t*, a patient is classified
    as having an event if the patient experienced the event between
    baseline and *t* (5 years in our case study), and as a non-event if
    the patient remained event-free at *t*. The time-dependent AUC
    evaluates whether predicted probabilities were higher for cases than
    for non-case.

Clearly the last of these is most relevant.

This is easy to compute using the concordance function in the survival
package There is some uncertainty in the literature about the original
Harrell formulation versus Uno’s suggestion to re-weight the time scale
by the factor 1/*G*<sup>2</sup>(*t*) where *G* is the censoring
distribution. There is more detailed information in the concordance
vignette found in the survival package.

We also propose to calculate Uno’s time-dependent AUC at a specific time
horizon *t*.  
More explanations and details are in the paper.

The time horizon to calculate the time-dependent measures was set to 5
years. Values close to 1 indicate good discrimination ability, while
values close to 0.5 indicated poor discrimination ability.

<details>
<summary>
Click to expand code
</summary>

``` r
if (!require("pacman")) install.packages("pacman")
library(pacman)
pacman::p_load(survival,
               Hmisc,
               pec,
               timeROC)

harrell_C_gbsg5 <- concordance(Surv(ryear, rfs) ~ PI, 
                               gbsg5, 
                               reverse = TRUE)

harrell_C_gbsg5_pgr <- concordance(Surv(ryear, rfs) ~ PI_pgr, 
                               gbsg5, 
                               reverse = TRUE)

# Uno's C
Uno_C_gbsg5 <- concordance(Surv(ryear, rfs) ~ PI, 
                           gbsg5, 
                           reverse = TRUE,
                           timewt = "n/G2")

Uno_C_gbsg5_pgr <- concordance(Surv(ryear, rfs) ~ PI_pgr, 
                           gbsg5, 
                           reverse = TRUE,
                           timewt = "n/G2")
```

</details>
<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External

</div>

</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External + PGR

</div>

</th>
</tr>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Harrell C - Validation data
</td>
<td style="text-align:right;">
0.66
</td>
<td style="text-align:right;">
0.63
</td>
<td style="text-align:right;">
0.69
</td>
<td style="text-align:right;">
0.68
</td>
<td style="text-align:right;">
0.65
</td>
<td style="text-align:right;">
0.69
</td>
</tr>
<tr>
<td style="text-align:left;">
Uno C - Validation data
</td>
<td style="text-align:right;">
0.65
</td>
<td style="text-align:right;">
0.62
</td>
<td style="text-align:right;">
0.68
</td>
<td style="text-align:right;">
0.67
</td>
<td style="text-align:right;">
0.64
</td>
<td style="text-align:right;">
0.70
</td>
</tr>
</tbody>
</table>

Concordance was between 0.64 and 0.68. The extended model slightly
improved discrimination ability compared to the basic model.

<details>
<summary>
Click to expand code
</summary>

``` r
if (!require("pacman")) install.packages("pacman")
library(pacman)
pacman::p_load(survival,
               Hmisc,
               pec,
               timeROC)

# External validation
Uno_gbsg5 <-
  timeROC(
    T = gbsg5$ryear, delta = gbsg5$rfs,
    marker = gbsg5$PI,
    cause = 1, weighting = "marginal", times = 4.95,
    iid = TRUE
  )

# External validation with pgr
Uno_gbsg5_pgr <-
  timeROC(
    T = gbsg5$ryear, delta = gbsg5$rfs,
    marker = gbsg5$PI_pgr,
    cause = 1, weighting = "marginal", times = 4.95,
    iid = TRUE
  )
# NOTE: if you have a lot of data n > 2000, standard error computation may be really long.
# In that case, please use bootstrap percentile to calculate confidence intervals.
```

</details>
<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External

</div>

</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External + PGR

</div>

</th>
</tr>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Uno AUC
</td>
<td style="text-align:right;">
0.7
</td>
<td style="text-align:right;">
0.65
</td>
<td style="text-align:right;">
0.76
</td>
<td style="text-align:right;">
0.73
</td>
<td style="text-align:right;">
0.68
</td>
<td style="text-align:right;">
0.78
</td>
</tr>
</tbody>
</table>

The time-dependent AUCs at 5 years were in the external validation were
0.70 and 0.73 for the basic and extended model, respectively.

### 1.3 Calibration

Calibration is the agreement between observed outcomes and predicted
probabilities. For example, in survival models, a predicted survival
probability at a fixed time horizon *t* of 80% is considered reliable if
it can be expected that 80 out of 100 will survive among patients
received a predicted survival probability of 80%. Calibration can be
assessed at a fixed time point (e.g. at 5 years), and globally
(considering the entire range of the data). In addition, different level
of calibration assessment can be estimated according to the level of
information available in the data. When individual data of development
and validation set are available, full assessment of calibration is
possible. Calibration at fixed time point is possible when baseline
hazard at fixed time point and coefficient are available. When only
coefficients are available, limited assessment of calibration is
possible.

In this scenario, we can evaluate calibration only at fixed time point
*t* (i.e. 5 years) since we may have baseline survival at time *t* (5
years) and coefficients of the model.

Since different level of information may be available, different level
of calibration can be estimated: mean, weak, and moderate calibration.

-   Mean calibration can be estimated:

    -   at a fixed time point:
        -   using the Observed and Expected ratio at time t;

-   Weak calibration can be estimated:

    -   at a fixed time point
        -   using intercept and slope as the coefficient of cloglog
            transformation of predicted probabilities in Cox model.
            Possible to determine intercept after adjusting for slope.

-   Moderate calibration can estimated:

    -   at a fixed time point:
        -   using flexible calibration curve, complemented with ICI,
            E50, E90.

More detailed explanations are available in the paper.

When a risk prediction model has been developed and published in the
literature, individual data are probably not available. If the model
equation is provided including the coefficients and the baseline at
fixed time point *t* (e.g. 5 years), we could validate the risk
prediction model in our external data. Typically, the model equation is
provided in terms of predicted survival at a fixed time point *t*.

#### 1.3.1 Mean calibration - fixed time point

The mean calibration at fixed time point (e.g. at 5 years) can be
estimated using the Observed and Expected ratio. The observed is
estimated using the complementary of the Kaplan-Meier curve at the fixed
time point. The expected is estimated using the average predicted risk
of the event at the fixed time point.

<details>
<summary>
Click to expand code
</summary>

``` r
if (!require("pacman")) install.packages("pacman")
library(pacman)
pacman::p_load(survival,
               Hmisc,
               pec,
               timeROC,
               rms)
##  Observed / Expected ratio at time t ------------
# Observed: 1-Kaplan Meier at time (t)
horizon <- 5
obj <- summary(survfit(Surv(ryear, rfs) ~ 1, 
                       data = gbsg5), 
               times = horizon)

OE <- (1 - obj$surv) / mean(gbsg5$pred5)
OE_pgr <- (1 - obj$surv) / mean(gbsg5$pred5_pgr)
```

</details>
<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External

</div>

</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External + PGR

</div>

</th>
</tr>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
OE ratio
</td>
<td style="text-align:right;">
1.07
</td>
<td style="text-align:right;">
0.95
</td>
<td style="text-align:right;">
1.2
</td>
<td style="text-align:right;">
1.03
</td>
<td style="text-align:right;">
0.92
</td>
<td style="text-align:right;">
1.16
</td>
</tr>
</tbody>
</table>

Observed and Expected ratio is 1.07 (95% CI: 0.95 - 1.20) for the basic
model and 1.03 (95% CI: 0.92 - 1.16) for the extended model.

#### 1.3.2 Weak calibration - fixed time point

Weak calibration using intercept and slope as the coefficient of cloglog
transformation of predicted probabilities in Cox model.

<details>
<summary>
Click to expand code
</summary>

``` r
if (!require("pacman")) install.packages("pacman")
library(pacman)
pacman::p_load(survival,
               Hmisc,
               pec,
               timeROC,
               rms)

# cloglog and center for the basic and extended model
lp.val <- log(-log(1 - gbsg5$pred5))   # lp = cloglog
lp.val_pgr <- log(-log(1 - gbsg5$pred5_pgr)) 
center <- mean(lp.val)  # center
center_pgr <- mean(lp.val_pgr)  # center


### Model with a slope and an intercept
horizon <- 5
f.val <- coxph(Surv(gbsg5$ryear, gbsg5$rfs) ~ lp.val)  
slope <- f.val$coefficients[1]
slope.se <- sqrt(vcov(f.val)[[1, 1]])

f.val_pgr <- coxph(Surv(gbsg5$ryear, gbsg5$rfs) ~ lp.val_pgr)  
slope_pgr <- f.val_pgr$coefficients[1]
slope.se_pgr <- sqrt(vcov(f.val_pgr)[[1, 1]])
 
### same procedure to find the intercept, now with slope-adjusted lp
f.val.offset <- coxph(Surv(gbsg5$ryear, gbsg5$rfs) ~ offset(slope*lp.val))
sf <- survfit(f.val.offset, conf.type = "log-log")
log.H <- log(-log(tail(sf$surv[sf$time <= horizon], 1)))   
int <- log.H - mean(slope*lp.val)
log.H.upper <- log(-log(tail(sf$upper,1)))
int.se <- (log.H-log.H.upper)/qnorm(.975)

# With marker
f.val.offset_pgr <- coxph(Surv(gbsg5$ryear, gbsg5$rfs) ~
                        offset(slope_pgr*lp.val_pgr))
sf_pgr <- survfit(f.val.offset_pgr, conf.type = "log-log")
log.H_pgr <- log(-log(tail(sf_pgr$surv[sf_pgr$time <= horizon], 1)))   
int_pgr <- log.H_pgr - mean(slope_pgr*lp.val_pgr)
log.H.upper_pgr <- log(-log(tail(sf_pgr$upper,1)))
int.se_pgr <- (log.H_pgr-log.H.upper_pgr)/qnorm(.975)
```

</details>
<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External

</div>

</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External + PGR

</div>

</th>
</tr>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Calibration intercept
</td>
<td style="text-align:right;">
0.15
</td>
<td style="text-align:right;">
0.02
</td>
<td style="text-align:right;">
0.29
</td>
<td style="text-align:right;">
0.14
</td>
<td style="text-align:right;">
0.01
</td>
<td style="text-align:right;">
0.28
</td>
</tr>
<tr>
<td style="text-align:left;">
Calibration slope
</td>
<td style="text-align:right;">
1.08
</td>
<td style="text-align:right;">
0.84
</td>
<td style="text-align:right;">
1.32
</td>
<td style="text-align:right;">
1.17
</td>
<td style="text-align:right;">
0.94
</td>
<td style="text-align:right;">
1.40
</td>
</tr>
</tbody>
</table>

Calibration intercept (adjusted for the slope) was 0.15 and 0.14 for the
basic and extended model , respectively.  
Calibration slope was 1.08 and 1.17 for the basic and extended model,
respectively.

#### 1.3.3 Moderate calibration - fixed time point

Moderate calibration at fixed time point can be assessed using flexible
calibration curve, complemented with ICI, E50, E90 as suggested by
Austin et al.

Calibration curve: it is a graphical representation of calibration
in-the-large and calibration. It shows:

-   on the *x-axis* the predicted survival (or risk) probabilities at a
    fixed time horizon (e.g. at 5 years);

-   on the *y-axis* the observed survival (or risk) probabilities at a
    fixed time horizon (e.g. at 5 years);

-   The 45-degree line indicates the good overall calibration. Points
    below the 45-degree line indicates that the model overestimate the
    observed risk. If points are above the 45-degree line, the model
    underestimate the observed risk; The observed probabilities
    estimated by the Kaplan-Meier curves (in case of survival) or by the
    complementary of the Kaplan-Meier curves (in case of risk in absence
    of competing risks) are represented in terms of percentiles of the
    predicted survival (risk) probabilities.

-   Integrated Calibration Index (ICI): it is the weighted difference
    between smoothed observed proportions and predicted probabilities in
    which observations are weighted by the empirical density function of
    the predicted probabilities;

-   E50 and E90 denote the median, the 90th percentile of the absolute
    difference between observed and predicted probabilities of the
    outcome at time *t*;

<details>
<summary>
Click to expand code
</summary>

``` r
if (!require("pacman")) install.packages("pacman")
library(pacman)
pacman::p_load(survival,
               Hmisc,
               pec,
               timeROC,
               rms)

# Calibration plot --------
# Basic model
gbsg5 <- data.frame(gbsg5)
gbsg5$pred.cll <- log(-log(1 - gbsg5$pred5))

# Extended model
gbsg5$pred.cll_pgr <- log(-log(1 - gbsg5$pred5_pgr))


# Estimate actual risk - basic model
vcal <- cph(Surv(ryear, rfs) ~ rcs(pred.cll, 3),
            x = T,
            y = T,
            surv = T,
            data = gbsg5
) 

# Estimate actual risk - extended model
vcal_pgr <- cph(Surv(ryear, rfs) ~ rcs(pred.cll_pgr, 3),
            x = T,
            y = T,
            surv = T,
            data = gbsg5
) 


dat_cal <- cbind.data.frame(
  "obs" = 1 - survest(vcal, 
                      times = 5, 
                      newdata = gbsg5)$surv,
  
  "lower" = 1 - survest(vcal, 
                        times = 5, 
                        newdata = gbsg5)$upper,
  
  "upper" = 1 - survest(vcal, 
                        times = 5, 
                        newdata = gbsg5)$lower,
  
  "pred" = as.vector(gbsg5$pred5),
  
  
   "obs_pgr" = 1 - survest(vcal_pgr, 
                      times = 5, 
                      newdata = gbsg5)$surv,
  
  "lower_pgr" = 1 - survest(vcal_pgr, 
                        times = 5, 
                        newdata = gbsg5)$upper,
  
  "upper_pgr" = 1 - survest(vcal_pgr, 
                        times = 5, 
                        newdata = gbsg5)$lower,
  
  "pred_pgr" = as.vector(gbsg5$pred5_pgr)
  
)


# Flexible calibration curve - basic model
dat_cal <- dat_cal[order(dat_cal$pred), ]

par(xaxs = "i", yaxs = "i", las = 1)
plot(
  dat_cal$pred, 
  dat_cal$obs,
  type = "l", 
  lty = 1, 
  xlim = c(0, 1),
  ylim = c(0, 1), 
  lwd = 2,
  xlab = "Predicted probability",
  ylab = "Observed probability", bty = "n"
)
lines(dat_cal$pred, 
      dat_cal$lower, 
      type = "l", 
      lty = 2, 
      lwd = 2)
lines(dat_cal$pred, 
      dat_cal$upper,
      type = "l", 
      lty = 2, 
      lwd = 2)
abline(0, 1, lwd = 2, lty = 2, col = "red")
title("Basic model - validation data ")


# Flexible calibration curve - extended model
dat_cal <- dat_cal[order(dat_cal$pred_pgr), ]
par(xaxs = "i", yaxs = "i", las = 1)
plot(
  dat_cal$pred_pgr, 
  dat_cal$obs_pgr,
  type = "l", 
  lty = 1, 
  xlim = c(0, 1),
  ylim = c(0, 1), 
  lwd = 2,
  xlab = "Predicted probability",
  ylab = "Observed probability", 
  bty = "n"
)
lines(dat_cal$pred_pgr, 
      dat_cal$lower_pgr, 
      type = "l", 
      lty = 2, 
      lwd = 2)
lines(dat_cal$pred_pgr, 
      dat_cal$upper_pgr,
      type = "l", 
      lty = 2, 
      lwd = 2)
abline(0, 1, lwd = 2, lty = 2, col = "red")
title("Extended model - validation data ")

# Numerical measures ---------------
# Basic model
absdiff_cph <- abs(dat_cal$pred - dat_cal$obs)

numsum_cph <- c(
  "ICI" = mean(absdiff_cph),
  setNames(quantile(absdiff_cph, c(0.5, 0.9)), c("E50", "E90"))
)

# Extended model ------
absdiff_cph_pgr <- abs(dat_cal$pred_pgr - dat_cal$obs_pgr)

numsum_cph_pgr <- c(
  "ICI" = mean(absdiff_cph_pgr),
  setNames(quantile(absdiff_cph_pgr, c(0.5, 0.9)), c("E50", "E90"))
)
```

</details>

<img src="imgs/02_predsurv/cal_rcs_metrics-1.png" width="672" style="display: block; margin: auto;" /><img src="imgs/02_predsurv/cal_rcs_metrics-2.png" width="672" style="display: block; margin: auto;" />

<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
ICI
</th>
<th style="text-align:right;">
E50
</th>
<th style="text-align:right;">
E90
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
External data
</td>
<td style="text-align:right;">
0.04
</td>
<td style="text-align:right;">
0.04
</td>
<td style="text-align:right;">
0.06
</td>
</tr>
<tr>
<td style="text-align:left;">
External data + PGR
</td>
<td style="text-align:right;">
0.03
</td>
<td style="text-align:right;">
0.02
</td>
<td style="text-align:right;">
0.06
</td>
</tr>
</tbody>
</table>

In the validation, ICI at 5 years was 0.04 and 0.03 for the basic and
extended model, respectively.

#### 1.3.4 Calibration when only coefficients of the model are available

When only coefficients of the development model is available and the
baseline survival is not provided, only visual assessment of calibration
is possible based on Kaplan-Meier curves between risk groups.

<details>
<summary>
Click to expand code
</summary>

``` r
# PI by groups
gbsg5$group1 <- cut(gbsg5$PI, 
                    breaks = quantile(gbsg5$PI, 
                                      probs = seq(0, 1, 0.25)),
                    include.lowest = TRUE)


par(las = 1, xaxs = "i", yaxs = "i")
plot(survfit(Surv(ryear, rfs) ~ group1, data = gbsg5),
  bty = "n", 
  xlim = c(0, 5), 
  ylim = c(0, 1), 
  lwd = 2, 
  col = "black",
  lty = 2, 
  xlab = "Time (years)", 
  ylab = "Survival probability"
)
title("A - basic model", adj = 0)

# Extended model
gbsg5$group1_pgr <- cut(gbsg5$PI_pgr, 
                    breaks = quantile(gbsg5$PI_pgr, 
                                      probs = seq(0, 1, 0.25)),
                    include.lowest = TRUE)


par(las = 1, xaxs = "i", yaxs = "i")
plot(survfit(Surv(ryear, rfs) ~ group1_pgr, 
             data = gbsg5),
     bty = "n",
     xlim = c(0, 5), 
     ylim = c(0, 1), 
     lwd = 2, 
     col = "black",
     lty = 2, 
     xlab = "Time (years)", 
     ylab = "Survival probability"
)
title("B - extended model", adj = 0)
```

</details>

<img src="imgs/02_predsurv/km-1.png" width="672" /><img src="imgs/02_predsurv/km-2.png" width="672" />

### 1.4 Overall performance measures

Some overall performance measures are proposed using survival data:

-   Brier score: it is the squared differences between observed and
    predicted values at fixed time point (e.g. at 5 years);

-   Scaled Brier score (known as Index of prediction accuracy): it
    improves interpretability by scaling the Brier Score.

<details>
<summary>
Click to expand code
</summary>

``` r
brier_gbsg5 <-
  brier_score(
    tfup = gbsg5$ryear, status = gbsg5$rfs,
    thorizon = 4.95, survival = 1 - gbsg5$pred5
  )

brier_gbsg5b_pgr <-
  brier_score(
    tfup = gbsg5$ryear, status = gbsg5$rfs,
    thorizon = 4.95, survival = 1 - gbsg5$pred5_pgr
  )

## Overall measures: Bootstrap confidence intervals ---------------
B <- 100
horizon <- 4.95
set.seed(12345)
boots_ls <- lapply(seq_len(B), function(b) {
  
  # Resample validation data
  data_boot <- gbsg5[sample(nrow(gbsg5), replace = TRUE), ]

  
  # Get overall measures on boot validation data
  BS_boot <- brier_score(
    tfup = data_boot$ryear, status = data_boot$rfs,
    thorizon = 4.95, survival = 1 - data_boot$pred5
  )
  
  # Get overall measures on boot validation data
  BS_boot_pgr <- brier_score(
    tfup = data_boot$ryear, status = data_boot$rfs,
    thorizon = 4.95, survival = 1 - data_boot$pred5_pgr
  )
    
  brier_boot <- BS_boot["Brier"]
  scaled_brier <- BS_boot["IPA"]
  brier_boot_pgr <- BS_boot_pgr["Brier"]
  scaled_brier_pgr <- BS_boot_pgr["IPA"]
  #.. can add other measure heres, eg. concordance
  
  cbind.data.frame(
    "Brier" = brier_boot,
    "Scaled Brier" = scaled_brier,
    "Brier with PGR" = brier_boot_pgr,
    "Scaled Brier with PGR" = scaled_brier_pgr)
})

df_boots <- do.call(rbind.data.frame, boots_ls)
```

</details>
<table class="table table-striped" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1">
</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External

</div>

</th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="3">

<div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">

External + PGR

</div>

</th>
</tr>
<tr>
<th style="text-align:left;">
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
<th style="text-align:right;">
Estimate
</th>
<th style="text-align:right;">
Lower .95
</th>
<th style="text-align:right;">
Upper .95
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Brier
</td>
<td style="text-align:right;">
0.22
</td>
<td style="text-align:right;">
0.20
</td>
<td style="text-align:right;">
0.23
</td>
<td style="text-align:right;">
0.21
</td>
<td style="text-align:right;">
0.20
</td>
<td style="text-align:right;">
0.22
</td>
</tr>
<tr>
<td style="text-align:left;">
Scaled Brier
</td>
<td style="text-align:right;">
0.12
</td>
<td style="text-align:right;">
0.08
</td>
<td style="text-align:right;">
0.19
</td>
<td style="text-align:right;">
0.15
</td>
<td style="text-align:right;">
0.11
</td>
<td style="text-align:right;">
0.21
</td>
</tr>
</tbody>
</table>

As expected the overall performance measures were lower in the external
validation. Including information about PGR slightly improved the
overall performance.

## 2. Clinical utility

Discrimination and calibration measures are essential to assess the
prediction performance but insufficient to evaluate the potential
clinical utility of a risk prediction model for decision making. When
new markers are available, clinical utility assessment evaluates whether
the extended model helps to improve decision making.  
Clinical utility is measured by the net benefit that includes the number
of true positives and the number of false positives. For example, in
time-to-event models, the true positives reflect the benefit of being
event free for a given time horizon using additional interventions such
as additional treatments, personalized follow-up or additional
surgeries. The false positives represent the harms of unnecessary
interventions.  
Generally, in medicine, clinicians accepts to treat a certain number of
patients for which interventions are unnecessary to be event free for a
given time horizon. So, false negatives (the harm of not being event
free for a given time horizon) are more important than false positives
(the harm of unnecessary interventions). Thus, net benefit is the number
of true positives classifications minus the false positives
classifications weighted by a factor related to the harm of not
preventing the event versus unnecessary interventions. The weighting is
derived from the threshold probability to death (one minus survival
probability) using a defined time horizon (for example 5 years since
diagnosis). For example, a threshold of 10% implies that additional
interventions for 10 patients of whom one would have experience the
event in 5 years if untreated is acceptable (thus treating 9 unnecessary
patients). This strategy is compared with the strategies of treat all
and treat none patients. If overtreatment is harmful, a higher threshold
should be used.  
The net benefit is calculated as:

<img src="https://render.githubusercontent.com/render/math?math=%5Chuge%7B%5Cfrac%7BTP%7D%7Bn%7D-%5Cfrac%7BFP%7D%7Bn%7D*%5Cfrac%7Bp_t%7D%7B1-p_t%7D%7D">

*TP*=true positive patients  
*FP*=false positive patients  
*n*=number of patients and *p*<sub>t</sub> is the risk threshold.

For survival data *TP* and *FP* is calculated as follows:  
<img src="https://render.githubusercontent.com/render/math?math=%5CLarge%7BTP%20%3D%20%5B1-S(t)%7C%20X%3D1%5D*P(X%3D1)*n%7D">

<img src="https://render.githubusercontent.com/render/math?math=%5CLarge%7BFP%20%3D%20%5BS(t)%7C%20X%3D1%5D*P(X%3D1)*n%7D">

where  
*S(t)* survival at time *t*  
*X=1* where the predicted probability at time *t* is *p*<sub>t</sub>

And the the decision curve is calculated as follows:

1.  Choose a time horizon (in this case 5 years);
2.  Specify a risk threshold which reflects the ratio between harms and
    benefit of an additional intervention;
3.  Calculate the number of true positive and false positive given the
    threshold specified in (2);
4.  Calculate the net benefit of the survival model;
5.  Plot net benefit on the *y-axis* against the risk threshold on the
    *x-axis*;
6.  Repeat steps 2-4 for each model consideration;
7.  Repeat steps 2-4 for the strategy of assuming all patients are
    treated;
8.  Draw a straight line parallel to the *x-axis* at y=0 representing
    the net benefit associated with the strategy of assuming that all
    patients are not treated.

Given some thresholds, the model/strategy with higher net benefit
represents the one that potentially improves clinical decision making.
However, poor discrimination and calibration lead to lower net benefit.

<details>
<summary>
Click to expand code
</summary>

``` r
# External data
# Run decision curve analysis

# Development data
# Model without PGR
gbsg5 <- as.data.frame(gbsg5)
dca_gbsg5 <- stdca(
  data = gbsg5, outcome = "status", ttoutcome = "ryear",
  timepoint = 5, predictors = "pred5", xstop = 1.0,
  ymin = -0.01, graph = FALSE
)
# Model with PGR
dca_gbsg5_pgr <- stdca(
  data = gbsg5, outcome = "status", ttoutcome = "ryear",
  timepoint = 5, predictors = "pred5_pgr", xstop = 1,
  ymin = -0.01, graph = FALSE
)

# Decision curves plot
par(xaxs = "i", yaxs = "i", las = 1)
plot(dca_gbsg5$net.benefit$threshold,
  dca_gbsg5$net.benefit$pred5,
  type = "l", 
  lwd = 2, 
  lty = 1,
  xlab = "Threshold probability in %", 
  ylab = "Net Benefit",
  xlim = c(0, 1), 
  ylim = c(-0.10, 0.60), 
  bty = "n",
  cex.lab = 1.2, 
  cex.axis = 1
)
lines(dca_gbsg5$net.benefit$threshold, 
      dca_gbsg5$net.benefit$none, 
      type = "l", 
      lwd = 2, 
      lty = 4)
lines(dca_gbsg5$net.benefit$threshold, 
      dca_gbsg5$net.benefit$all, 
      type = "l", 
      lwd = 2, 
      col = "darkgray")
lines(dca_gbsg5_pgr$net.benefit$threshold,
      dca_gbsg5_pgr$net.benefit$pred5_pgr, 
      type = "l", 
      lwd = 2, 
      lty = 5)
legend("topright",
  c(
    "Treat All",
    "Original model",
    "Original model + PGR",
    "Treat None"
  ),
  lty = c(1, 1, 5, 4), lwd = 2, 
  col = c("darkgray", "black", "black", "black"),
  bty = "n"
)
title("B External data", adj = 0, cex = 1.5)
```

</details>

    ## [1] "pred5: No observations with risk greater than 84%, and therefore net benefit not calculable in this range."

    ## [1] "pred5_pgr: No observations with risk greater than 88%, and therefore net benefit not calculable in this range."

<img src="imgs/02_predsurv/dca-1.png" width="672" style="display: block; margin: auto;" />

The potential net benefit at 23% threshold of the prediction model was
0.27, 0.28 for the basic and extended model in the development data,
respectively. This means that the model might identify approximately
27/28 patients out of 100 who may develop recurrence or may die within 5
years since diagnosis and thus adjuvant chemotherapy may help to reduce
recurrence or mortality. For validation data, the potential net benefit
was 0.42 for the basic and extended model.

Moreover, net benefit can be defined in terms of reduction of avoidable
interventions (e.g adjuvant chemotherapy per 100 patients) by:

<img src="https://render.githubusercontent.com/render/math?math=%5Chuge%7B%5Cfrac%7BNB_%7Bmodel%7D%20-%20NB_%7Ball%7D%7D%7B(p_t%2F%20(1-p_t))%7D*100%7D%0A">

where *NB*<sub>model</sub> is the net benefit of the prediction model,
*NB*<sub>all</sub> is the net benefit of the strategy treat all and
*p*<sub>*t*</sub> is the risk threshold.

## Reproducibility ticket

``` r
sessionInfo()
```

    ## R version 4.1.2 (2021-11-01)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 19044)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] gtsummary_1.5.0    forcats_0.5.1      stringr_1.4.0      dplyr_1.0.7       
    ##  [5] purrr_0.3.4        readr_2.1.1        tidyr_1.1.4        tibble_3.1.6      
    ##  [9] tidyverse_1.3.1    kableExtra_1.3.4   knitr_1.36         rms_6.2-0         
    ## [13] SparseM_1.81       timeROC_0.4        pec_2021.10.11     prodlim_2019.11.13
    ## [17] Hmisc_4.6-0        ggplot2_3.3.5      Formula_1.2-4      lattice_0.20-45   
    ## [21] survival_3.2-13    pacman_0.5.1      
    ## 
    ## loaded via a namespace (and not attached):
    ##   [1] TH.data_1.1-0             colorspace_2.0-2         
    ##   [3] ellipsis_0.3.2            class_7.3-19             
    ##   [5] rprojroot_2.0.2           htmlTable_2.3.0          
    ##   [7] fs_1.5.1                  base64enc_0.1-3          
    ##   [9] rstudioapi_0.13           listenv_0.8.0            
    ##  [11] MatrixModels_0.5-0        fansi_0.5.0              
    ##  [13] mvtnorm_1.1-3             lubridate_1.8.0          
    ##  [15] xml2_1.3.3                codetools_0.2-18         
    ##  [17] splines_4.1.2             jsonlite_1.7.2           
    ##  [19] pROC_1.18.0               gt_0.3.1                 
    ##  [21] caret_6.0-90              broom_0.7.10             
    ##  [23] cluster_2.1.2             dbplyr_2.1.1             
    ##  [25] png_0.1-7                 riskRegression_2021.10.10
    ##  [27] compiler_4.1.2            httr_1.4.2               
    ##  [29] backports_1.3.0           assertthat_0.2.1         
    ##  [31] Matrix_1.3-4              fastmap_1.1.0            
    ##  [33] cli_3.1.0                 htmltools_0.5.2          
    ##  [35] quantreg_5.86             tools_4.1.2              
    ##  [37] gtable_0.3.0              glue_1.5.1               
    ##  [39] reshape2_1.4.4            Rcpp_1.0.7               
    ##  [41] cellranger_1.1.0          vctrs_0.3.8              
    ##  [43] svglite_2.0.0             nlme_3.1-153             
    ##  [45] conquer_1.2.1             broom.helpers_1.5.0      
    ##  [47] iterators_1.0.13          timeDate_3043.102        
    ##  [49] gower_0.2.2               xfun_0.28                
    ##  [51] globals_0.14.0            rvest_1.0.2              
    ##  [53] lifecycle_1.0.1           future_1.23.0            
    ##  [55] polspline_1.1.19          MASS_7.3-54              
    ##  [57] zoo_1.8-9                 scales_1.1.1             
    ##  [59] ipred_0.9-12              hms_1.1.1                
    ##  [61] parallel_4.1.2            sandwich_3.0-1           
    ##  [63] RColorBrewer_1.1-2        yaml_2.2.1               
    ##  [65] gridExtra_2.3             rpart_4.1-15             
    ##  [67] latticeExtra_0.6-29       stringi_1.7.6            
    ##  [69] highr_0.9                 foreach_1.5.1            
    ##  [71] checkmate_2.0.0           lava_1.6.10              
    ##  [73] mets_1.2.9                rlang_0.4.12             
    ##  [75] pkgconfig_2.0.3           systemfonts_1.0.3        
    ##  [77] matrixStats_0.61.0        evaluate_0.14            
    ##  [79] cmprsk_2.2-10             recipes_0.1.17           
    ##  [81] htmlwidgets_1.5.4         tidyselect_1.1.1         
    ##  [83] here_1.0.1                parallelly_1.29.0        
    ##  [85] plyr_1.8.6                magrittr_2.0.1           
    ##  [87] R6_2.5.1                  generics_0.1.1           
    ##  [89] multcomp_1.4-17           DBI_1.1.1                
    ##  [91] pillar_1.6.4              haven_2.4.3              
    ##  [93] foreign_0.8-81            withr_2.4.3              
    ##  [95] nnet_7.3-16               future.apply_1.8.1       
    ##  [97] modelr_0.1.8              crayon_1.4.2             
    ##  [99] utf8_1.2.2                tzdb_0.2.0               
    ## [101] rmarkdown_2.11            timereg_2.0.1            
    ## [103] jpeg_0.1-9                readxl_1.3.1             
    ## [105] grid_4.1.2                data.table_1.14.2        
    ## [107] ModelMetrics_1.2.2.2      reprex_2.0.1             
    ## [109] digest_0.6.29             webshot_0.5.2            
    ## [111] numDeriv_2016.8-1.1       stats4_4.1.2             
    ## [113] munsell_0.5.0             viridisLite_0.4.0
