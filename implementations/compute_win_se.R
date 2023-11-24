# code to manually compute contrasts and compute se on the contrast
# adapted from https://nmmichalak.github.io/nicholas_michalak/blog_entries/2018/nrg07/nrg07.html

#get_win_se <- function(){
  
  library(tidyverse)
  library(knitr)
  library(AMCP)
  library(MASS)
  library(afex)
  
  # select from dplyr
  select <- dplyr::select
  recode <- dplyr::recode
  
  data <- read.csv("Documents/GitHub/PSY2R/resources/BIRD.csv")
  c1 <- c(1, -1, 0)
  c2 <- c(1, 0, -1)
  c3 <- c(1, -2, 1)
  n = 16
  ng = 4
  nw = 3
  
  ldata <- data %>%
    pivot_longer(
      cols = 3:5,
      names_to = "Spacing",
      values_to = "Yield")%>%
    dplyr::select(subj,Group,Spacing,Yield)
  ldata$Group <- as.factor(ldata$Group)
  ldata$subj <- as.factor(ldata$subj)
  ldata$Spacing <- as.factor(ldata$Spacing)
  ldata$Spacing <- relevel(ldata$Spacing, "TWENTY")
  ldata$c1 <- rep(c1, times=n)
  ldata$c2 <- rep(c2, times=n)
  ldata$c3 <- rep(c3, times=n)
  ldata$b1 <- rep(c(0.5, 0.5, -0.5, -0.5), each=nw*ng)
  ldata$b2 <- rep(c(1.0, -1.0, 0.0, -0.0), each=nw*ng)
  ldata$b3 <- rep(c(0.0, 0.0, 1.0, -1.0), each=nw*ng)
  
  a = mean(as.matrix(data[,-c(1,2)]) %*% c1)
  b = mean(as.matrix(data[,-c(1,2)]) %*% c2)
  c = mean(as.matrix(data[,-c(1,2)]) %*% c3)
  est <- c(a, b, c/2)
  est_w <- est
  
  n <- nrow(data)
  
  # sum of squares for the contrast
  assc <- n * a^2 / sum(c1^2)
  bssc <- n * b^2 / sum(c2^2)
  cssc <- n * c^2 / sum(c3^2)
  ssc <- c(assc, bssc, cssc)
  
  # mean squared error is computed for each 
  mse_c1 <- anova(lm(Yield ~ c1 + c1:b1 + c1:b2 + c1:b3 + c1:subj, data = ldata))['c1:subj','Mean Sq']
  mse_c2 <- anova(lm(Yield ~ c2 + c2:b1 + c2:b2 + c2:b3 + c2:subj, data = ldata))['c2:subj','Mean Sq']
  mse_c3 <- anova(lm(Yield ~ c3 + c3:b1 + c3:b2 + c3:b3 + c3:subj, data = ldata))['c3:subj','Mean Sq']
  #mse_KM <- anova(lm(Yield ~ c3 + c3:b1 + c3:b2 + c3:b3 + c3:subj, data = ldata))['c3:b1','Mean Sq']
  
  c1se <- sqrt(mse_c1 * sum(c1^2 / n))
  c2se <- sqrt(mse_c2 * sum(c2^2 / n))
  c3se <- sqrt(mse_c3 * sum(c3^2 / n))/2 # to half the contrast values
  se <- c(c1se, c2se, c3se)
  

#attempt at calculating interaction contrasts NOT MATCHING PSY OUTPUT  
  #cs_b <- gl(4, 3, labels = c("1","2","3","4"))
  #g1_v_g2 <- c(1,-1,0,0)[cs_b]
  #cs_w <- gl(3, 4,labels = c("1","2","3"))
  #w1con <- c(1, -1, 0)[cs_w]
  #w1b2 <- g1_v_g2*w1con
  #se_w1b2 <- sqrt(mse_c1*sum(w1b2^2/n))
  ####
  
  list(se, est_w) 
#}
