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

###############################################################
# between subject confidence intervals
###############################################################

# first fit the aov, see https://s3-eu-west-1.amazonaws.com/s3-euw1-ap-pe-ws4-cws-documents.ri-prod/9781138024571/chapters/ch11/1_Least-Square_RM_ANOVA_in_R_Using_aov().JLH.pdf
fit <- aov(Yield~Group*Spacing+Error(subj/Spacing), data=data)
estimates <- fit$subj$coefficients
contrast_coefficients <- c(1,-1) #to compare groups 1 and 2
estimate <- estimates[[1]] * contrast_coefficients[2] #extract from table

mse_bs <- sum(fit$subj$residuals^2)/fit$subj$df.residual
n <- fit$subj$df.residual
se_bs <- se_cont(mse_bs,c(1,-1),n)

a <- 0.05
k <- 1.0 #k is the number of families. if you're just running bs contrasts, that's one family.
critical_t <- qt(a/2.0*k,fit$subj$df.residual,lower.tail = FALSE) 
ci_bs <- c(estimate - critical_t*se_bs,estimate + critical_t*se_bs) #need test statistic from contrast. looking for CI ±6.519


###############################################################
# within subject confidence intervals
###############################################################



###############################################################
# between x within subject confidence intervals
###############################################################
