### K. Garner, 2024.
### My attempt to use emmeans to get something that matches the Psy output
### and the loose implementation of Psy that we have so far in R.
rm(list=ls())

##### things to know up front
## can everything we rely on internally use the explicit defining of factor levels
# from a dataframe

##### install packages
library(tidyverse)
library(emmeans)
library(afex)
source("../functions/gcr_crit.R")
source('functions/t_indiv.R')
source('functions/general.R')

##############################################################
### Target values aka Psy output:
# Raw CIs (scaled in Dependent Variable units)
# -------------------------------------------------------
#   Contrast      Value        SE           ..CI limits..
# Lower       Upper
# -------------------------------------------------------
# B1            2.958       2.116      -3.888       9.805
# B2          -14.083       2.992     -23.765      -4.401
# B3           -2.500       2.992     -12.182       7.182
# W1           -1.750       0.832      -4.203       0.703
# B1W1         -8.000       1.665     -14.978      -1.022
# B2W1          5.000       2.354      -4.868      14.868
# B3W1         -3.000       2.354     -12.868       6.868
# W2           -3.000       1.014      -5.990      -0.010
# B1W2        -19.250       2.028     -27.753     -10.747
# B2W2          8.750       2.869      -3.275      20.775
# B3W2         -6.750       2.869     -18.775       5.275
# W3           -0.250       0.459      -1.602       1.102
# B1W3          1.625       0.917      -2.220       5.470
# B2W3          0.625       1.297      -4.812       6.062
# B3W3          0.375       1.297      -5.062       5.812

# emmeans implementation
afex_options(emmeans_model = "multivariate")
# emmeans_model: Which model should be used by emmeans for follow-up
# analysis of ANOVAs (i.e., objects pf class "afex_aov")? Default is
# "univariate" which uses the aov model object (if present). The other
# option is "multivariate" which uses the lm model object (which is an
# object of class "mlm" in case repeated-measures factors are present).

data <- read.csv("resources/BIRD.csv")
data_long <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)

# perform the statistical model
mod <- aov_ez("subj","Yield", data_long, within = "Spacing",between = "Group")


########################################################################
# Get contrast values
#######################################################################

# contrasts
## only test specified tests
sum_emm_btwn <- emmeans(mod, "Group")
# Compute estimated marginal means (EMMs) for specified factors or factor
# combinations in a linear model; and optionally, comparisons or contrasts
# among them. EMMs are also known as least-squares means.
con <- list(
  "12vs34" = c(0.5, 0.5, -0.5, -0.5),
  "1vs2" = c(1, -1, 0, 0),
  "3vs4" = c(0, 0, 1, -1)
)
btwn_con <- contrast(sum_emm_btwn, con)
### this replicates the contrast estimates that we get from Psy
# contrast estimate   SE df t.ratio p.value
# 12vs34       2.96 2.12 12   1.398  0.1873
# 1vs2       -14.08 2.99 12  -4.707  0.0005
# 3vs4        -2.50 2.99 12  -0.836  0.4197

confint(btwn_con) # DOES NOT MATCH PSY OUTPUT THEREFORE WE NEED FUNCTIONS!
# contrast estimate   SE df lower.CL upper.CL
# 12vs34       2.96 2.12 12    -1.65     7.57
# 1vs2       -14.08 2.99 12   -20.60    -7.56
# 3vs4        -2.50 2.99 12    -9.02     4.02

####### Now do within
sum_emm_win <- emmeans(mod, "Spacing")
# Compute estimated marginal means (EMMs) for specified factors or factor
# combinations in a linear model; and optionally, comparisons or contrasts
# among them. EMMs are also known as least-squares means.

win_con <- list(
  "20vs40" = c(1, -1, 0),
  "20vs60" = c(1, 0, -1),
  "Quad" = c(0.5, -1, 0.5)
)
con_win <- contrast(sum_emm_win, win_con) # matches Psy output
confint(con_win) # DOES NOT MATCH PSY OUTPUT

##### Now do between x within interactions
sum_emm_int <- emmeans(mod, c("Group", "Spacing"))
# now defining the contrasts is going to be a bit fiddly but should be
# doable
n_within = 3
n_group = 4

win_full <- lapply(win_con, function(x) rep(x, each = n_group))
btwn_full <- lapply(con, function(x) rep(x, times = n_within))
int_conts <- lapply(btwn_full, function(x) lapply(win_full, function(y) x * y))
con_int <- contrast(sum_emm_int, int_conts)

# Psy definitions
nsubs = 16 # total subs
ngroups = 4 # this is true
nwithin = 3
DFE = nsubs - ngroups
s = min(ngroups-1, nwithin-1)
m =  (abs(ngroups - nwithin) -1)/2
n = (DFE - nwithin)/2
se_c1 <- 1.66
theta = gcr_crit(.05, s, m, n)
vE = 12
cc = sqrt((vE*theta)/(1-theta))
contrast_ci(se_c1, cc)

############################################################################
# single t-CIs
# get the critical constant for the between contrasts
v_e = length(data$subj) - max(data$Group) # df error
critical_constant = cc_individual(v_e)
se_cont = summary(btwn_con)[,"SE"] # get the se for the contrast
cis = contrast_ci(critical_constant, se_cont)
output = summary(btwn_con)
output$lower = output$estimate - cis
output$upper = output$estimate + cis


############################################################################
# Bonferroni t CIs






############################################################################
# Post-hoc CIs

