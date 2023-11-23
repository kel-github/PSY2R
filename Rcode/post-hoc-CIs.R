# to-do
# 1. implement between/w-in CIs
rm(list=ls())
library(tidyverse)

###############################################################
# functions
###############################################################
se_cont <- function(MSE, contrast_vector, n){
  # compute the standard error of the contrast
  # --
  # Kwargs
  # MSE: mean square error for the effect of interest
  # contrast_vector: a contrast vector - e.g. one 
  #  comparing 2 groups would be c(1, -1)
  # n [f, 1]: df error
  sqrt(MSE * sum(contrast_vector^2/n))
}

contrast_ci <- function(cc, se_contrast){
  # compute the confidence interval using the
  # critical constant and the standard error of the
  # contrast
  # --
  # Kwargs
  # cc [int] - appropriate critical constant
  # se_contrast 
  
  cc * se_contrast
}

cc_between <- function(v_b, v_e, alpha = 0.05){
  # compute critical constant for between subject contrasts\
  # formula (7) from Bird, 2002, https://doi.org/10.1177/0013164402062002001
  # sqrt(v_b * F_alpha;v_b,v_e)
  # v_b = df between
  # v_w = df within
  # v_e = df error
  # --
  # Kwargs
  # v_b: [f, 1] df between - THIS IS THE DF BTWN FOR THE MODEL
  # v_e: [f, 1] df error
  # alpha: [f 1] type 1 error rate
  
  # first get critical constant F
  crit_F <- qf(alpha, v_b, v_e, lower.tail = FALSE)
  sqrt(v_b * crit_F)
}

cc_within <- function(v_w, v_e, alpha = .05){
  # compute critical constant for within subject contrasts\
  # formula (8) from Bird, 2002, https://doi.org/10.1177/0013164402062002001
  # sqrt((v_w*v_e)/(v_e-v_w+1) * F_alpha;v_w,v_e-v_w+1)
  # v_w = df within
  # v_e = df error
  # --
  # Kwargs
  # v_b: [f, 1] df between - THIS IS THE DF BTWN FOR THE CONTRAST
  # v_e: [f, 1] df error
  # alpha: [f 1] type 1 error rate
  crit_F <- qf(alpha, v_w, v_e-v_w+1, lower.tail = FALSE)
  sqrt((v_w*v_e)/(v_e-v_w+1) * crit_F)
}

###############################################################
# read in data and shape
###############################################################
data <- read.csv("BIRD.csv")
dat <- data
data <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)
data$Group <- as.factor(data$Group)
data$subj <- as.factor(data$subj)
data$Spacing <- as.factor(data$Spacing)
data$Spacing <- relevel(data$Spacing, "TWENTY")

# some info
n = length(unique(data$Group))

# first fit the aov, see https://s3-eu-west-1.amazonaws.com/s3-euw1-ap-pe-ws4-cws-documents.ri-prod/9781138024571/chapters/ch11/1_Least-Square_RM_ANOVA_in_R_Using_aov().JLH.pdf
fit <- aov(Yield~Group*Spacing+Error(subj/Spacing), data=data)

###############################################################
# between subject confidence intervals
###############################################################
# define contrasts
# defining contrasts as a list here for lapply use
# these contrasts are defined for use in manually
# written functions for the computation of CC and 
# se etc
contrasts_b <- list(c1 <- c(0.5, 0.5, -0.5, -0.5),
                    c2 <- c(1.0, -1.0, 0, 0),
                    c3 <- c(0, 0, 1, -1))

v_b <- 3 # model has 4 groups
MSE_b <- sum(fit$subj$residuals^2)/fit$subj$df.residual
v_e <- fit$subj$df.residual
#n = length(unique(data$subj))

# NOTE: when n = 12 (residual df, B1 CIs are correct, but not B2 or B3)
se_b <- lapply(contrasts_b, se_cont, MSE = MSE_b, n=12)
cc_b <- cc_between(v_b, v_e)

# ci value to be added or subtracted from contrast value
# get group means
ms <- data %>% group_by(Group) %>% summarise(mu = mean(Yield))
est_b <- unlist(do.call(cbind, lapply(contrasts_b, function(x) x %*% ms$mu)))
ci_b <- unlist(lapply(se_b, contrast_ci, cc=cc_b))
est_b - ci_b
est_b + ci_b

###############################################################
# within subject confidence intervals
###############################################################
# starting with within subject confidence intervals
## first I compute the standard error for the win contrasts
contrasts_w <- list(c1 = c(1, -1, 0),
                    c2 = c(1, 0, -1),
                    c3 = c(1, -2, 1))
# load standard errors computed from compute_win_se.R
load("win_se.RData")
se_w <- se
rm(se)
v_w <- length(contrasts_w$c1) - 1
cc_w <- cc_within(v_w, v_e)

ci_w <- lapply(se_w, contrast_ci, cc=cc_w)

# make this pretty
est_w - do.call(cbind, ci_w)
est_w
est_w + do.call(cbind, ci_w)

###############################################################
# between x within subject confidence intervals
###############################################################
