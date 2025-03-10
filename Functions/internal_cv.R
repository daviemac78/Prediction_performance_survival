#' Calculate optimism-corrected bootstrap internal validation for AUC, Brier and Scaled Brier Score
#' @param db data to calculate the optimism-corrected bootstrap
#' @param B number of bootstrap sample (default 10)
#' @param time follow-up time
#' @param status indicator variable (0=censored, 1=event)
#' @param formula_model formula for the model (Cox model)
#' @param pred.time time horizon as predictor
#' @param formula_ipcw formula to calculate inverse probability censoring weighting
#'
#' @return
#'
#' @author Daniele Giardiello
#'
#' @examples

# Use pacman to check whether packages are installed, if not load
if (!require("pacman")) install.packages("pacman")
library(pacman)

pacman::p_load(
  rio,
  survival,
  rms,
  pec,
  tidyverse,
  timeROC,
  riskRegression
)


bootstrap_cv <- function(db, B = 10,
                         time,
                         status,
                         formula_model,
                         pred.time,
                         formula_ipcw) {
  frm_model <- as.formula(formula_model)
  frm_ipcw <- as.formula(formula_ipcw)
  db$id <- 1:nrow(db)


  # Duplicate data
  db_ext <- db %>% slice(rep(row_number(), B))
  db_ext$.rep <- with(db_ext, ave(seq_along(id), id, FUN = seq_along)) # add an index identifying the replications

  db_tbl <- db_ext %>%
    group_by(.rep) %>%
    nest() %>%
    rename(
      orig_data = data,
      id_boot = .rep
    )

  # Create bootstrap samples
  sample_boot <- function(db, B) {
    db_boot <- matrix(NA, nrow = nrow(db) * B, ncol = ncol(db))
    sample_row <- list()
    for (j in 1:B) {
      sample_row[[j]] <- sample(nrow(db), size = nrow(db), replace = TRUE)
    }
    sample_row <- unlist(sample_row)
    db_boot <- db[sample_row, ]
    db_boot$id_boot <- sort(rep(1:B, nrow(db)))
    db_boot <- db_boot %>%
      group_by(id_boot) %>%
      nest() %>%
      rename(boot_data = data)
    return(db_boot)
  }

  # Join original data and the bootstrap data in a nested tibble
  a <- sample_boot(db, B)
  b <- a %>% left_join(db_tbl)

  # Create optimism-corrected performance measures
  b <- b %>% mutate(
    cox_boot = map(
      boot_data,
      ~ coxph(frm_model, data = ., x = T, y = T)
    ),
    
    cox_apparent = map(
      orig_data,
      ~ coxph(frm_model, data = ., x = T, y = T)
    ),
    
    Harrell_C_app =
      map2_dbl(
      orig_data, cox_apparent,
      ~ concordance(Surv(.x[[time]], .x[[status]]) 
                    ~ predict(.y, newdata = .x),
                    reverse = TRUE)$concordance
    ),
    
    Harrell_C_orig =
      map2_dbl(
        orig_data, cox_boot,
        ~ concordance(Surv(.x[[time]], .x[[status]]) 
                      ~ predict(.y, newdata = .x),
                      reverse = TRUE)$concordance
      ),
    
    Harrell_C_boot =
      map2_dbl(
        boot_data, cox_boot,
        ~ concordance(Surv(.x[[time]],.x[[status]]) 
                      ~ predict(.y, newdata = .x),
                      reverse = TRUE)$concordance
      ),
    
    Harrell_C_diff = map2_dbl(
      Harrell_C_boot, Harrell_C_orig,
      function(a, b) {
        a - b
      }
    ),
    
    Uno_C_app =
      map2_dbl(
        orig_data, cox_apparent,
        ~ concordance(Surv(.x[[time]], .x[[status]]) 
                      ~ predict(.y, newdata = .x),
                      reverse = TRUE,
                      timewt = "n/G2")$concordance
      ),
    
    Uno_C_orig =
      map2_dbl(
        orig_data, cox_boot,
        ~ concordance(Surv(.x[[time]], .x[[status]]) 
                      ~ predict(.y, newdata = .x),
                      reverse = TRUE,
                      timewt = "n/G2")$concordance
      ),
    
    Uno_C_boot =
      map2_dbl(
        boot_data, cox_boot,
        ~ concordance(Surv(.x[[time]],.x[[status]]) 
                      ~ predict(.y, newdata = .x),
                      reverse = TRUE,
                      timewt = "n/G2")$concordance
      ),
    
    Uno_C_diff = map2_dbl(
      Uno_C_boot, Uno_C_orig,
      function(a, b) {
        a - b
      }
    ),
    
    AUC_app = map2_dbl(
      orig_data, cox_apparent,
      ~ timeROC(
        T = .x[[time]], delta = .x[[status]],
        marker = predict(.y, newdata = .x),
        cause = 1, weighting = "marginal", times = pred.time,
        iid = FALSE
      )$AUC[[2]]
    ),
    
    AUC_orig = map2_dbl(
      orig_data, cox_boot,
      ~ timeROC(
        T = .x[[time]], delta = .x[[status]],
        marker = predict(.y, newdata = .x),
        cause = 1, weighting = "marginal", times = pred.time,
        iid = FALSE
      )$AUC[[2]]
    ),
    
    AUC_boot = map2_dbl(
      boot_data, cox_boot,
      ~ timeROC(
        T = .x[[time]], delta = .x[[status]],
        marker = predict(.y, newdata = .x),
        cause = 1, weighting = "marginal", times = pred.time,
        iid = FALSE
      )$AUC[[2]]
    ),
    
    AUC_diff = map2_dbl(
      AUC_boot, AUC_orig,
      function(a, b) {
        a - b
      }
    ),
    
    Score_app = map2(
      orig_data, cox_apparent,
      ~ Score(list("Cox" = .y),
        formula = frm_ipcw,
        data = .x, times = pred.time,
        cens.model = "km",
        metrics = "brier",
        summary = "ipa"
      )$Brier[[1]]
    ),
    
    Brier_app = map_dbl(Score_app, ~ .x$Brier[[2]]),
    IPA_app = map_dbl(Score_app, ~ .x$IPA[[2]]),
    Score_orig = map2(
      orig_data, cox_boot,
      ~ Score(list("Cox" = .y),
        formula = frm_ipcw,
        data = .x, times = pred.time,
        cens.model = "km",
        metrics = "brier",
        summary = "ipa"
      )$Brier[[1]]
    ),
    
    Brier_orig = map_dbl(Score_orig, ~ .x$Brier[[2]]),
    IPA_orig = map_dbl(Score_orig, ~ .x$IPA[[2]]),
    Score_boot = map2(
      boot_data, cox_boot,
      ~ Score(list("Cox" = .y),
        formula = frm_ipcw,
        data = .x, times = pred.time,
        cens.model = "km",
        metrics = "brier",
        summary = "ipa"
      )$Brier[[1]]
    ),
    
    Brier_boot = map_dbl(Score_boot, ~ .x$Brier[[2]]),
    IPA_boot = map_dbl(Score_boot, ~ .x$IPA[[2]]),
    Brier_diff = map2_dbl(
      Brier_boot, Brier_orig,
      function(a, b) {
        a - b
      }
    ),
    
    IPA_diff = map2_dbl(
      IPA_boot, IPA_orig,
      function(a, b) {
        a - b
      }
    )
  )

  # Generate output
  AUC_corrected <- b$AUC_app[1] - mean(b$AUC_diff)
  Brier_corrected <- b$Brier_app[1] - mean(b$Brier_diff)
  IPA_corrected <- b$IPA_app[1] - mean(b$IPA_diff)
  Harrell_C_corrected <- b$Harrell_C_app[1] - mean(b$Harrell_C_diff)
  Uno_C_corrected <- b$Uno_C_app[1] - mean(b$Uno_C_diff)
  res <- c("AUC corrected" = AUC_corrected, 
           "Brier corrected" = Brier_corrected, 
           "IPA corrected" = IPA_corrected, 
           "Harrell C corrected" = Harrell_C_corrected,
           "Uno C corrected" = Uno_C_corrected)
  return(res)
}
