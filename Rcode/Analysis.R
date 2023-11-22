#title: Bird data

#summation Tests----
library(here)
library(afex)
library(emmeans)
afex_options(emmeans_model = "multivariate")

data <- read.csv(here("BIRD.csv"))

library(tidyverse)
data_long <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)

a1<- aov_ez("subj","Yield",data_long, within = "Spacing",between = "Group")
a1
library(knitr)
knitr::kable(nice(a1))

#contrasts
m3 <- emmeans(a1,c("Group","Spacing"))
#order is by Spacing 

#extra things you don't really need but good to know-----
#get F ratio and PEsq 
Partial_Eta2 <- function(F, df) {
  t <- sqrt(F)
  pes <- t^2/(t^2 + df)
  return(pes) 
}

#write function for output table
Contrast_Table <- function(out) { 
  out <- as.data.frame(out) %>%
    mutate(F.ratio = t.ratio^2, 
           # lower.CI = estimate - t.ratio*SE,
           # upper.CI = estimate + t.ratio*SE,
           pes = Partial_Eta2(F.ratio, df)
    )
  print(kable(out))
}

#contrasts-----

#main effect Group 
c1 <- list(
  "12vs34" <- c(1,1,-1,-1,1,1,-1,-1,1,1,-1,-1), #Groups 1 1 -1 -1 x 3 within repeats
  "1vs2" <- c(1,-1,0,0,1,-1,0,0,1,-1,0,0), #Groups 1 -1 0 0 x 3 within repeats
  "3vs4" <- c(0,0,1,-1,0,0,1,-1,0,0,1,-1) #groups 0 0 1 -1
)
between_out <-contrast(m3,c1)
Contrast_Table(between_out)
#this doesn't match with PSY but attempts at individual vs simultaneous CI---
# confint(between_out)
# confint(as.glht(between_out))

#main effect Spacing
c2 <- list(
  "20vs40" = c(1,1,1,1,-1,-1,-1,-1,0,0,0,0),
  "20vs60" = c(1,1,1,1,0,0,0,0,-1,-1,-1,-1), #1 0 -1, x 4 groups
  "Quad" = c(1,1,1,1,-2,-2,-2,-2,1,1,1,1) # 1 -2 1, quadratic trend
)
within_out <- contrast(m3,c2)
Contrast_Table(within_out)



man <- manova(cbind(Sepal.Length, Petal.Length) ~ Species, data = dat)
root_info <- summary(man)

#confint(within_out)
#confint(as.glht(within_out))

#between x within interaction contrasts
c3 <-list(
  B1W1 = `12vs34`*`20vs40`,
  B2W1 = `1vs2`*`20vs40`,
  B3W1 = `3vs4`*`20vs40`,
  B1W2 = `12vs34`*`20vs60`,
  B2W2 = `1vs2`*`20vs60`,
  B3W2 = `3vs4`*`20vs60`,
  B1W3 = `12vs34`*Quad,
  B2W3 = `1vs2`*Quad,
  B3W3 = `3vs4`*Quad
)
intx_out <- contrast(m3,c3)
Contrast_Table(intx_out) # add the F Value and partial eta square
# produce between x within post-hoc

# compute within x between confidence intervals according to PSY



#output----
sink("PSY_output.txt")
print(cat("//Between Subject Contrasts//"))
print(Contrast_Table(between_out))
print(confint(between_out))
confint(as.glht(between_out))
print(cat("//Within Subjects Contrasts//"))
print(Contrast_Table(within_out))
print(confint(within_out))
confint(as.glht(within_out))
print(cat("//Interaction Contrasts//"))
print(Contrast_Table(intx_out))
print(confint(intx_out))
confint(as.glht(intx_out))
sink()

