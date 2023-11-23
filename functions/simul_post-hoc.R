###############################################################
# critical constants
###############################################################
cc_between <- function(v_b, v_e, alpha = 0.05){
  # compute critical constant for between subject contrasts\
  # formula (7) from Bird, 2002, https://doi.org/10.1177/0013164402062002001
  # sqrt(v_b * F_alpha;v_b,v_e)
  # v_b = df between
  # v_w = df within
  # v_e = df error
  # --
  # Kwargs
  # v_b: [f, 1] df between 
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