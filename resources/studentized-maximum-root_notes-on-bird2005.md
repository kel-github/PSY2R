### Overview

PSY implements three methods of calculating simulatenous confidence intervals: Bonferroni, post-hoc, and Boik's Studentized Maximum Root (SMR). All of these methods use the same equation to calculate the standard error of the contrast, and the confidence interval itself. All of them also use estimates of how the variables correlate from something like a classic omnibus test. They differ in how they calculate a critical constant from the test output. Within each of them, there can also be multiple ways to calculate the critical constant, depending on whether the test is within-subjects, between-subjects, or between- and within-subjects.

This doc draws on the paper below to try and understand the method based on Boik's SMR. 

Bird & Hadzi-Pavlovic (2005). Studentized Maximum Root Procedures for Coherent Analyses of Two-Factor Fixed-Effects Designs. *Psychological Methods, 10(3), 352–366.* doi: 10.1037/1082-989X.10.3.352.

### Background

Imagine a J x K fixed effects design with factors A and B. Factor A has levels a_j (j = 1...J). Factor B has levels b_k (k = 1...K). The number of observations in each cell (subjects in each group) is n. 

Say that the factors are therapy and disorder, and we want to understand how each or the combination affects startle response.

##### A two-factor ANOVA says, 

$$
Y{_i}{_j}{_k} =  μ + α_j + β_k + αβ{_j}{_k} + ε{_i}{_j}{_k}
$$

That is, the outcome for this subject with this therapy and disorder is some intercept plus the influence of therapy, the influence of disorder, the combined influence of therapy and disorder, and some error.

##### A simple effects model for therapy says,

$$
Y{_i}{_j}{_k} = μ + α_j(b_k) + β_k + ε{_i}{_j}{_k}
$$



That is, the outcome for this subject is some constant plus the influence of therapy(in this disorder) plus the effect of this disorder plus some error.

##### A simple effects model for disorder says,

$$
Y{_i}{_j}{_k} = μ + α_j + β_k(a_j) + ε{_i}{_j}{_k}
$$





That is, the outcome for this subject is some constant plus the influence of therapy plus the influence of disorder(with this therapy) plus some error.

##### A cell means model says,

$$
Y{_i}{_j}{_k} = μ{_j}{_k} + ε{_i}{_j}{_k}
$$



That is, this person's outcome is the group mean for this therapy-disorder combo, plus some error.

#### Choosing a model

The two-factor ANOVA model is a classic, but it won't allow you to investigate the simple effects of A or B. Each of the simple effects models lets you do this. They ask whether, for example, the effects of therapy are stable over disorder, or whether the influence of disorder is stable over groups. So, they consider the factor of interest and its interactions with the other factor, but not the other factor's effect.

#### Making contrasts

C = a matrix of coefficients with J rows and K columns. 

For a factorial contrast, all rows and/or all columns must sum to zero. If all rows and columns sum to zero, you are testing an interaction.

You then apply this contrast, using matrix algebra, as C'μ. That is, transpose the contrast coefficient matrix, and multiply it by a matrix of means. The matrix of means will similarly have J rows and K columns. In practice, the matrix of means will hold sample rather than population means, which we represent with M rather than μ.

If you apply contrast coefficients as 
$$
c'_Aμc_B
$$
where c_A is a J vector and c_B is a K vector, and at least one of them sums to zero, you've run a product contrast. The rank of the coefficient matrix C=c_A x c'B is or should be 1. Product contrasts are special somehow -- I don't fully get how!

Simple effect contrasts can always be product contrasts. If c_A is a standard coefficient vector and c_B has a single non-zero value, that tests the simple effect of A.

### Studentized maximum root critical constants

#### Getting the test statistic

Bird (2005) covers how to calculate SMR for all the models described above. I'll stick with Model 1 for now. I unsure whether it's the most useful, but it's most familiar to me, and should be familiar to other psychology-trained researchers.

For an interaction contrast under Model 1, the test statistic is...
$$
R{_A}{_B} = L{_A}{_B} / MSE
$$
That is, the root of A and B is something called L, modified by its mean squared error. So what's L?
$$
L{_A}{_B} = max [n(c'_AMc_B)^2 / c'_Ac_Ac'_Bc_B] ~(Σ~c{_A}_j = Σ~c{_B}_k = 0)
$$
That is, L is the maximum value of the sum of squares of a product interaction contrast.

This is where all those contrast coefficient rules come in to play. For the product interaction contrast, the sum of the contrast coefficients across rows and columns must be zero.

##### Example

Assume that there are two therapies, CBT and DBT, and two disorders, GAD and cPSTD. We want to know if there's an effect of either or both factors on startle response. We select Model 1 to consider main effects and their interaction. 

Sample means are:

|      | GAD  | cPSTD |
| ---- | ---- | ----- |
| CBT  | 2.5  | 5.9   |
| DBT  | 3.6  | 4.1   |

Contrast coefficients are:

|           | GAD (k=1) | cPTSD (k=2) |
| --------- | --------- | ----------- |
| CBT (j=1) | 1         | -1          |
| DBT (j=2) | -1        | 1           |

With this in mind, 
$$
c'_AMc_B
$$
 = [1;-1] * M * [1, -1]

= [1 * [2.5, 5.9]; -1 * [3.6, 4.1]] * [-1,1]

= [2.5,5.9;-3.6,-4.1] * [-1,1]

= 

|      | GAD  | cPTSD |
| ---- | ---- | ----- |
| CBT  | 2.5  | -5.9  |
| DBT  | -3.6 | 4.1   |

Let's say n = 10.
$$
n (c'_AMc_B)^2
$$
= 

|      | GAD       | cPTSD     |
| ---- | --------- | --------- |
| CBT  | 274.9000  | -389.4000 |
| DBT  | -237.6000 | 380.5000  |

Next, calculate:
$$
c'_Ac_Ac'_Bc_B
$$
This is equal to [2 -2; -2 2].

Now, going back to,
$$
L{_A}{_B} = max [n(c'_AMc_B)^2 / c'_Ac_Ac'_Bc_B] ~(Σ~c{_A}_j = Σ~c{_B}_k = 0)
$$
...we find that L = 19.47.

##### 

##### The test statistic

Lastly, we estimate the mean squared error (i.e. each error squared, all of them summed, and all divided by the degrees of freedom), and use this to modify L to generate R, our test statistic. 
$$
R{_A}{_B} = L{_A}{_B} / MSE
$$


#### Looking up the critical value

We find the critical value with:
$$
SMR{_α};_p,_q,{_v}_E
$$

- alpha is the familywise error rate. 
- p is the minimum of (J - 1, K - 1)
- q is the maximum of (J - 1, K - 1). So, together, p and q capture the group degrees of freedom.
- v_E is N - JK. (I assume that N means the total number of observations, rather than the number of observations per cell.)

Like t and F, SMR is a distribution from which we select a critical value for our test. All of these are parameters that you use to select the relevant critical value from an SMR distribution. If our R value exceeds the critical value, we reject the null.

#### Calculating the critical constant

Lastly, we calculate a critical constant that can feed into our contrasts. We do this with...
$$
CC = √ SMR{_α};_p,_q,{_v}_E
$$
...a nice, simple step to finish on!