###############################################################
# critical constant for Individual-t method
###############################################################

cc_individual <- function(v_e, alpha = 0.05){
  # compute critical constant
  # formula on p205 from Bird, 2002, https://doi.org/10.1177/0013164402062002001
  #CC = t(v_e)_alpha/2
  #alpha is halved for two-sided CIs
  #inputs:
  #v_e = df error
  
  # get the t-Individual cc
  qt(alpha/2, v_e, lower.tail = FALSE)
}