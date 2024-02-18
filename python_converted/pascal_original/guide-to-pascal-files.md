# Kind of guide/map of Pascal code

Code implements routines to compute the largest eigenvalue (greatest characteristic root - GCR) of a covariance matrix that would be expected under the null hypothesis.  For this we need the CDF of the null.  

Assumptions:  Covariance matrix comes from an independent Wishart matrix (Wp(n,sigma))  
Response measures are continuous and normal.  

See Pillai (1965) for the CDF function (eqs (1 & 3))

Relevant files:  
GCR.pas  
PsyBaseStats.pas  

Functions in GCR.pas  

1. Ksmn(s, m, n)
  Get the constant value C(s,m,n) from equations 1 & 3 of Pillai (1965).  

2. RoyExact(s,m,n,x)
    An exact method for computing the GCR expected under the null.  
    Can be used when 2 >= s <= 6
    Hypothesis: this is following the algorithm from Venables (1974).\
    Looks like it is used to compute a value Pr which is defined dependent on the highest integer in s.  
    If the highest integer is 5 or 6 then Pr = 6 (I think) 
    
    Calls:  
    Ksmn - compute C(s,m,n).  

    BetaRoy - The function called here depends on n. If n <= 600, then IncBetaContFrac is called, if >600 then IncompleteBetaByPartsNLarge is called. The latter appears to do the job of the former, but putting together several parts. Both refer to the beta function defined in Roy (1957), page 202, A.9.1.2. This function is referred to as a complete beta function by Roy, and looks closely related to the beta function. It appears to sum a bunch of partial integrations, with respect to x_s, going from s to 1. Assuming it is the cdf for the probability of x, given s, summed over each level of s.  (am wondering if its incomplete because x doesn't get to zero? that could be false.)

    BetaZero - 



    
    

  



