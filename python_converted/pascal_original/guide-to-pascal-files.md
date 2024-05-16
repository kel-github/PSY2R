# Kind of guide/map of Pascal code

Code implements routines to compute the largest eigenvalue (greatest characteristic root - GCR) of a covariance matrix that would be expected under the null hypothesis.  For this we need the CDF of the null.  

Assumptions:  Covariance matrix comes from an independent Wishart matrix (Wp(n,sigma))  
Response measures are continuous and normal.  

See Pillai (1965) for the CDF function (eqs (1 & 3))

Relevant files:  
GCR.pas  
PsyBaseStats.pas  

Functions in GCR.pas:

file uses: PsyBaseStats
calls function gcr_Prob(s, m, n, x: float):\
            this function will either call gcr_Prob_Exact or gcr_Prob_Approx depending on the value of s, which determines whether the exact or approx method needs to be used.
calls function: gcr_Crit(p, s, m, n, lower, upper: float) regardless of which method was used to get the gcr_Prob

Procedure for s <= 4

Idea is to use numerical approximation over iterations of the incomplete beta function to get the integrated cdf for the probability of the largest root (eigenvalue) given s, m, & n



1. Ksmn(s, m, n)
  Get the constant value C(s,m,n) from equations 1 & 3 of Pillai (1965) - i.e. compute the constant term defined in equation 2
  see Bird (2002, p. 217) for further clarification on the below definition of s, m, and n
  s = min(v_b, v_w) … where v_b and v_w are the degrees of freedom for between and within
  m = (abs(v_b - v_w) -1)/2
  n = (v_e - v_w - 1)/2 … v_e = df error
 

2. RoyExact(s,m,n,x)
    An exact method for computing the cdf of the characteristic root (largest eigenvalue). 
    Note that the roots are greater than zero and less than unity owing to s1(s1+s2)-1 is almost everywere positive definite. 
    
    Can be used when 2 >= s <= 4, and n ≤ 600  
    Calls:  


    Ksmn - compute C(s,m,n).  
     BetaRoy(x, m, n: float) 
    
    if n ≤ 600 then this function uses: IncBetaContFrac(x,m,n,2)
    
      IncBetaContFrac refers to the numerical methods for approximating the incomplete beta distribution put forward by Boik and Robinson-Cox, 1998. 
      
      Pillai (1954, chapters 1 & 2, and 1965) show how the cdf of the greatest characteristic root can be otained by starting with s=2, evaluating the probability of the root being less than or equal to x for that s, using evaluation of incomplete beta functions, and then adding the result to the result for the next s. See Pillai (1954) eq. 2.3.2 for an example of when s=2. The magic comes from eq. 1.7.11 which shows that its possible to express [X] in terms of pseudo-determinants that are defined in terms of I and I0, where I is the incomplete beta function, and I_0 is the incomplete beta function with (parameter zero?).






      Based on Pillai (1954)'s on some distribution problems in multivariate analysis. pg. 45-46: outlines how the problem of obtaining the cumulative distribution of the largest root is quicker and easier when using certain functions of the incomplete beta functions rather than using the incomplete beta function itself. (also see chapters 1, 2, of)
        

    PLAN: map the code to the equations in Boik & Robinson-Cox, 1998, then map Boik & Robinson-Cox, 1998 to Pillai (1954)
    
    Both refer to the beta function defined in Roy (1957), page 202, A.9.1.2. This function is referred to as a complete beta function by Roy, and looks closely related to the beta function. It appears to sum a bunch of partial integrations, with respect to x_s, going from s to 1. Assuming it is the cdf for the probability of x, given s, summed over each level of s.  (am wondering if its incomplete because x doesn't get to zero? that could be false.)
    
    

    BetaZero - 



    
    

  



