###############################################################
# implementation of the post-hoc method
###############################################################
rm(list=ls())
library(tidyverse)
library(tidyverse)
library(knitr)
library(AMCP)
library(MASS)
library(afex)

# functions (dirs can change)
source("Documents/GitHub/PSY2R/functions/general.R")
source("Documents/GitHub/PSY2R/functions/simul_post-hoc.R")
source("Documents/GitHub/PSY2R/implementations/compute_win_se.R")
source("Documents/GitHub/PSY2R/functions/t_bonf_cc.R")

# implementations to be tidied up later

###############################################################
# read in data and shape
###############################################################
data <- read.csv("Documents/GitHub/PSY2R/resources/BIRD.csv")
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

#count n contrasts in family
n_contrasts.b <- length(contrasts_b)

#n = length(unique(data$subj))

se_b <- lapply(contrasts_b, se_cont, MSE = MSE_b, n=12)
cc_bonf <- cc_bonferroni(v_e, n_contrasts.b)

# ci value to be added or subtracted from contrast value
# get group means
ms <- data %>% group_by(Group) %>% summarise(mu = mean(Yield))
est_b <- unlist(do.call(cbind, lapply(contrasts_b, function(x) x %*% ms$mu)))

#get MOE (CC*SE)
moe_bonf.b <- unlist(lapply(se_b, contrast_ci, cc=cc_bonf))

est_b - moe_bonf.b
est_b + moe_bonf.b

###############################################################
# within subject confidence intervals
###############################################################
# starting with within subject confidence intervals
## first I compute the standard error for the win contrasts
contrasts_w <- list(c1 = c(1, -1, 0),
                    c2 = c(1, 0, -1),
                    c3 = c(1, -2, 1))
# load staard errors computed from compute_win_se.R
out <- get_win_se()

#count n contrasts in family
n_contrasts.w <- length(contrasts_w)

#contrast estimates
se_w <- out[[1]]
est_w <- out[[2]]
v_w <- length(contrasts_w$c1) - 1

#get t-Bonferroni crit constant
cc_bonf.w <- cc_bonferroni(v_e, n_contrasts.w)

#get MOE (CC*SE)
moe_bonf.w <- lapply(se_w, contrast_ci, cc=cc_bonf.w)

# make this pretty
est_w - do.call(cbind, moe_bonf.w)
est_w
est_w + do.call(cbind, moe_bonf.w)

###############################################################
# between x within subject confidence intervals
###############################################################
