# 0. Dependencies
# install.packages("dplyr")
library(dplyr)

col_remove <- list("subj")

# 1. Read in from CSV
data_file <- read.csv("test_dataset.csv")
col_remove_d <- `$`(data_file, col_remove)
data <- subset(data_file, select = -c(`subj`))

# 2. Organise into groups
data <- data %>% group_by(`Group`)
data_group[1]