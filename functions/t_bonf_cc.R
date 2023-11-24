###############################################################
# critical constant for t-Bonferroni method
###############################################################

cc_bonferroni <- function(v_e, ncontr_family, alpha = 0.05){
  # compute critical constant
  # formula on p205 from Bird, 2002, https://doi.org/10.1177/0013164402062002001
  #CC = t(v_e)_alpha/2*k where k is the number of contrast in a given family 
  #(i.e., n of contrasts between OR within OR int)
  #inputs:
  #v_e = df error
  #ncontr_family = k 
  
  # get the t-Bonferroni cc
  qt(alpha/(2*ncontr_family), v_e, lower.tail = FALSE)
}