


ibeta <- function(x,a,b){pbeta(x,a,b)*beta(a,b)}

gcr_cdf <- function(s, m, n, theta){
  if(s%%2 == 0){
    A <- matrix(0, nrow = s, ncol = s)
  } else {
    A <- matrix(0, nrow = s+1, ncol = s+1)
  }
  
  b <- c()
  for (i in 1:s){
    b[i] <- (ibeta(theta, m+i, n+1)^2)/2
    if((s-1)>=i) {
      for (j in i:(s-1)){
        b[j+1] <- (((m+j)/(m+j+n+1))*b[j])-(ibeta(theta, 2*m+i+j, 2*n+2)/(m+j+n+1))
        A[i, j+1] <- ibeta(theta, m+i, n+1)*ibeta(theta, m + j + 1, n + 1) - 2*b[j+1]
      }  
    }
  }
  
  if (s%%2 != 0 ){
    for (i in 1:s){
      A[i, s+1] <- ibeta(theta, m+i, n+1)
    }
    
    
  }
  A = A - t(A)
  c_fun <- function(s, m, n) {
    gamma_product <- c() 
    for (i in 1:s) {
      gamma_product[i] <- gamma((i+2*m+2*n+s+2)/2)/(gamma(i/2)*gamma((i+2*m+1)/2)*gamma((i+2*n+1)/2))
    }
    gamma_product <- prod(gamma_product)
    gamma_product*(pi^(s/2))
  }
  
  c_fun(s, m, n)*sqrt(det(A))
}


gcr_crit <- function(alpha, s, m, n){
  search_gcr <- function(s, m, n, alpha, x) 1-gcr_cdf(s, m, n, x)-alpha
  
  uniroot(search_gcr, interval = 0:1, s=s, m=m, n=n, alpha=alpha)$root
}