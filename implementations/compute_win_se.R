# code to manually compute contrasts and compute se on the contrast
# adapted from https://nmmichalak.github.io/nicholas_michalak/blog_entries/2018/nrg07/nrg07.html
library(tidyverse)


data <- read.csv("resources/BIRD.csv")

c1 <- c(1, -1, 0)
c2 <- c(1, 0, -1)
c3 <- c(0.5, -1, 0.5)
within_contr <-  matrix(cbind(c1, c2, c3), ncol = 3, byrow = TRUE)

b1 <- c(0.5, 0.5, -0.5, -0.5)
b2 <- c(1.0, -1.0, 0.0, -0.0)
b3 <- c(0.0, 0.0, 1.0, -1.0)
between_contr <-  matrix(cbind(b1, b2, b3), ncol = 4, byrow = TRUE)       
       
ldata <- data %>%
  pivot_longer(
    cols = 3:5)


# Should we require data to be in long format?


get_win_se <- function(data, subject_var = "subj", grouping_vars = "Group",
                       within_var = "name", dependent_var = "value",
                       within_contr, between_contr){

  n <- nrow(unique(data[subject_var]))
  ng <- nrow(unique(data[grouping_vars]))
  nw <- nrow(unique(data[within_var]))
  
  dep_dat <- data %>% pivot_wider(names_from = within_var, values_from = dependent_var) %>% 
    select(!any_of(c(subject_var, grouping_vars)))
  
  data[grouping_vars] <- as.factor(data %>% pull(grouping_vars))
  data[subject_var] <- as.factor(data %>% pull(subject_var))
  data[within_var] <- as.factor(data %>% pull(within_var))

  for (i in 1:nrow(within_contr)) {
    data[paste0("w",i)] <- rep(within_contr[i, ], times = n)  
  }
  
  for (i in 1:nrow(between_contr)) {
    data[paste0("b",i)] <- rep(between_contr[i, ], each = ng*nw)  
  }
  
  ests <- c()
  for(i in 1:nrow(within_contr)) {
    ests[paste0("ests_w", i)] <- mean(as.matrix(dep_dat) %*% within_contr[i, ])
  }

  formulas <- list()
  for (i in 1:nrow(within_contr)){
    within_name <- paste0("w", i)
    interact_terms <- paste0(within_name, ":", "b", 1:nrow(between_contr))
    formulas[[paste0("w", i)]] <- formula(paste0(dependent_var, "~", within_name, "+", paste0(interact_terms, collapse = " + ")," + ",  within_name, ":", subject_var))
  }

  # mean squared error is computed for each 
  mse_w_vec <- c()
  for (i in 1:nrow(within_contr)) {
    mse_w_vec[paste0("mse_w", i)] <- anova(lm(formulas[[i]], data = data))[paste0("w", i, ":", subject_var), 'Mean Sq']
  }

  se_vec <- c()
  for (i in seq_along(mse_w_vec)) {
    se_vec[paste0("mse_w", i)] <- sqrt(mse_w_vec[i] * sum(within_contr[i, ]^2 / n))
  }
  
  list(se_vec, ests) 
}

get_win_se(ldata, within_contr = within_contr, between_contr = between_contr)
