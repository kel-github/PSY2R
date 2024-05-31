# Kind of guide/map of Pascal code

Code implements routines to compute the largest eigenvalue (greatest characteristic root - GCR) of a covariance matrix that would be expected under the null hypothesis.  For this we need the CDF of the null.  

Assumptions:  Covariance matrix comes from an independent Wishart matrix (Wp(n,sigma))  
Response measures are continuous and normal.  

See Pillai (1965) for the CDF function (eqs (1 & 3))

Relevant files:  
GCR.pas  
PsyBaseStats.pas  

# How the critical GCR is computed in Psy software

## finding the critical value of x where p(x) >= x == alpha (desired p)

Note to self: double check direction of p(x) relative to x, and the relationship to alpha

To compute the critical greatest characteristic root, i.e. to obtain x, given the p(x) = .0275, Psy performs an algorithm (described in Brentzero) that computes the probability of multiple x's (using gcrProbExact or gcrProbApprox), until is finds the x that returns a 0 when computing p - p(x) - i.e. it systematically tests candidate xs, until it finds the one where the p(x >= x) is the same as the desired p (i.e. defined for hypothesis testing or for attaining confidence intervals).

### Relevant functions and resources

BrentZero:- is the function that performs the Brent algorithm to find the zero point


## computing p(x|s.m,n) >= alpha

One has to compute the cdf of the gcr|s,m,n using numerical approximation, that involves computing a constant and evaulating an incomplete beta funcion over successive values of s - i.e. the cdf is the constant multiplied by a hypergeometric series. This is achieved using fuctions:

Additionally, numerical accuracy of the approximation is improved (i.e. misrepresentations in floating point values) using the double sum method. See function '' and 


### Limitations

Can only evaluate s between 2 & 20