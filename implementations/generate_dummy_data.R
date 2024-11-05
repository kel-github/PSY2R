## generate data w 2 within subjects factors
# ------------------------------------------------------------
rm(list=ls())
n_subs <- 100
n_groups <- 4
within_levels <- c(2, 2)

data <- data.frame(sub_id = rep(1:n_subs, each = prod(within_levels)),
                   group = rep(1:n_groups,
                               each = prod(within_levels)*n_subs/n_groups),
                   withinA = rep(c(1:within_levels[1]),
                                   each = within_levels[2]),
                   withinB = rep(c(1:within_levels[2]), times=within_levels[1]),
                   y = rnorm(n_subs*prod(within_levels)))
