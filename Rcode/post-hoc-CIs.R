# thoughts and goals:
# 1. Kevin's confidence intervals use a value
# which is the square root of the relevant MANOVA T^2 statistic.
# Gonna read the 2002 EPM paper to really get the method
# and then re-decide what to do

# to-do
# 1. implement use of se.contrast to get the standard error on a contrast
# 2. use equations 7, 8, & 9 to compute the critical values for the CI computation

rm(list=ls())
library(tidyverse)

###############################################################
# functions
###############################################################
se_cont <- function(MSE, contrast_vector, n){
  # compute the standard error of the contrast
  # MSE: mean square error for the effect of interest
  # contrast_vector: a contrast vector - e.g. one 
  #  comparing 2 groups would be c(1, -1)
  sqrt(MSE * sum(contrast_vector^2/n))
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

# first fit the aov, see https://s3-eu-west-1.amazonaws.com/s3-euw1-ap-pe-ws4-cws-documents.ri-prod/9781138024571/chapters/ch11/1_Least-Square_RM_ANOVA_in_R_Using_aov().JLH.pdf
fit <- aov(Yield~Group*Spacing+Error(subj/Spacing), data=data)

###############################################################
# between subject confidence intervals
###############################################################

###############################################################
# within subject confidence intervals
###############################################################
# starting with within subject confidence intervals
## first I compute the standard error for the win contrasts


# the below doesn't give the Kevin Bird, 2002 values
within_ses <- se.contrast(fit, t(as.matrix(tmp))) 

# can we corroborate this using the formula 3 from Bird 2002?
summary(fit)

se_cont <- function(MSE, contrast_vector){
  sqrt(MSE * sum(contrast_vector^2/n))
}

###############################################################
# between x within subject confidence intervals
###############################################################

# the below is useful for knowing how to code contrast vectors
# but not needed for our purposes as we only need the original
# contrast vector not replicated over subs
# see https://rdrr.io/r/stats/se.contrast.html
a_lev <- gl(3, 16, labels = c("twenty", "forty", "sixty"))
tw_v_ft <- c(1,-1,0)[a_lev]
tw_v_sx <- c(1, 0, -1)[a_lev]
quad <- c(1,-2,1)[a_lev]
tmp <- rbind(tw_v_ft, tw_v_sx, quad)