#title: Bird data

#summation Tests----

install.packages("here")
install.packages("afex")
install.packages("emmeans")
library(here)
library(afex)
library(emmeans)

afex_options(emmeans_model = "multivariate")

data <- read.csv("../resources/BIRD.csv")

library(tidyverse)
data_long <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)

a1<- aov_ez("subj","Yield",data_long, within = "Spacing",between = "Group")
class(a1)

library(chk)
object <-chklist(a1)
object = .chk.list(object, ...)
library(knitr)
knitr::kable(nice(a1))

#contrasts
m3 <- emmeans(a1,c("Group","Spacing"))

#order is by Spacing 

#extra things you don't really need but adds to the regular contrast table-----

Partial_Eta2 <- function(F, df) {
  t <- sqrt(F)
  pes <- t^2/(t^2 + df)
  return(pes) 
}

#should get it to extract n from the model instead of hardcoding 16 in this function
#also this is for repeated measures only
Bonferronit <- function(T, k, df, alpha=.05) {
  bonft <- ((T*alpha)/2*k)*(16-1)
  return(bonft)
}


#write function for output table
Contrast_Table <- function(out, k) { 
  out <- as.data.frame(out) %>%
    mutate(F.ratio = t.ratio^2, 
           pes = Partial_Eta2(F.ratio, df),
           k = k,
           bonft = Bonferronit(t.ratio, k, df)
    )
  print(kable(out))
}


Descriptives <- function(.data, .dv, ...) {
  out <- .data %>%
    group_by(...) %>%
    dplyr::summarise(mean = mean({{ .dv }}),
                     n = n(),
                     sd = sd({{ .dv }}),
                     se = sd({{ .dv }})/sqrt(n))
}



#contrasts-----

#main effect Group 
c1 <- list(
  "12vs34" <- c(1,1,-1,-1,1,1,-1,-1,1,1,-1,-1), #Groups 1 1 -1 -1 x 3 within repeats
  "1vs2" <- c(1,-1,0,0,1,-1,0,0,1,-1,0,0), #Groups 1 -1 0 0 x 3 within repeats
  "3vs4" <- c(0,0,1,-1,0,0,1,-1,0,0,1,-1) #groups 0 0 1 -1
)
between_out <-contrast(m3,c1)
Contrast_Table(between_out, 3)

#this doesn't match with PSY but attempts at individual vs simultaneous CI---
# confint(between_out)
# confint(as.glht(between_out))

#main effect Spacing
c2 <- list(
  "20vs40" = c(1,1,1,1,-1,-1,-1,-1,0,0,0,0),
  "20vs60" = c(1,1,1,1,0,0,0,0,-1,-1,-1,-1), #1 0 -1, x 4 groups
  "Quad" = c(1,1,1,1,-2,-2,-2,-2,1,1,1,1) # 1 -2 1, quadratic trend
)
within_out <- summary(contrast(m3,c2))
Contrast_Table(within_out,3)

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
c3 <-list(
  B1W1 = "12vs34"*"20vs40"
)

intx_out <- contrast(m3,c3)
Contrast_Table(intx_out, 9) # add the F Value and partial eta square
# produce between x within post-hoc

# compute within x between confidence intervals according to PSY

intx_out <- summary(contrast(m3,c3))

Contrast_Table(intx_out)



#single factor repeated measures compute CI
#this generates the closest CIs to PSY but not exact and also annoying to have to compute the mean and sd manually
library(MBESS)

descrip_main <- Descriptives(data_long, Yield, Group)
groupedSD_main <- Descriptives(data_long, Yield)

mbessCI <- ci.c(means=c(27.3, 41.4, 30.2, 32.7), s.anova=8.05, c.weights=c(.5, .5, -.5, -.5), 
     n=c(12, 12, 12, 12), N=48, conf.level=.95)

mbessCI_B2 <- ci.c(means=c(27.3, 41.4, 30.2, 32.7), s.anova=8.05, c.weights=c(1,-1,0,0), 
                n=c(12, 12, 12, 12), N=48, conf.level=.95)

#output----
sink("PSY_output.txt")
print(cat("//Between Subject Contrasts//"))
print(Contrast_Table(between_out))
print(cat("//Within Subjects Contrasts//"))
print(Contrast_Table(within_out))
print(cat("//Interaction Contrasts//"))
print(Contrast_Table(intx_out))
sink()

