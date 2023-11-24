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

cc_btwn_win <- function(v_b, v_w, v_e, alpha = 1 - 0.05){
  # compute the critical constrant for between/within using the 
  # Tracy-Widom method of Johnstone (2009) 149.171.76.156
  #
  # Kwargs:
  # -- v_b [1, f] df between
  # -- v_w [1, f] df within
  # -- v_e [1, f] df error
  # -- alpha [1, f] 1 - type 1 error rate
  # 
  # f_alpha = alphath percentile of F1
  # F1 = f_alpha (F1 is the Tracy- Widom distribution)
  # theta_alpha = exp^(mu + f_alpha*sigma) / (1 + e^mu + f_alpha*sigma) eq (6)
  # 
  # s = min(v_b, v_w) # these are from Kevin Bird, 2002, EPM
  # m = (abs(v_b - v_w) - 1)/2
  # n = (v_e - v_w - 1)/2
  # N = 2*(s + m + n) + 1
  #
  # conversion to Johnstone parameters - see (8)
  # p = s
  # m = s + 2n + 1
  # n = s + 2m + 1
  # 
  # now get definition of parameters to compute theta_alpha
  # mu = 2*log(tan(phi + gamma)/2)
  # sigma^3 = 16/(N^2) * 1/(sin^2 (phi + gamma) sin(phi) sin (gamma))
  # 
  # mu = 2 log tan ((phi + gamma)/2)  eq (9)
  # sigma_3 = 16/(N^2) * 1/(sin^2(phi + gamma) sin(phi) sin(gamma))
  #
  # sin(gamma/2)^2 = (s - 1/2)/N
  # so gamma = 2 * sin^-1 sqrt((s - 1/2)/N)
  #
  # sin(phi/2)^2 (s + 2n + 1/2)/N
  # so phi = 2 * sin^-1 sqrt((s + 2n + 1/2)/N)
  #
  # first use rmstat package to get f_alpha
  f_alpha <- RMTstat::qtw(alpha)
  
  # compute s, m & n
  s = min(v_b, v_w)
  m = (abs(v_b - v_w) - 1.0)/2.0
  n = (abs(v_e - v_w - 1.0)/2.0)
  N = 2.0*(s+m+n) + 1.0
  # now compute gamma and phi
  gamma = 2.0 * asin( sqrt( (s - 0.5) / N )  )
  phi = 2.0 * asin( sqrt( (s + 2.0*n + 0.5) / N  ))   
  
}