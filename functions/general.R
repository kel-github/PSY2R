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