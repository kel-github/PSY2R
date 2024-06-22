#This code will see the steps of emmeans line by line to see what it is doing. 

#First we will run the get_contrasts_tests.R to load the values that we load onto emmean.
#install packages and load libraries 

install.packages("here")
install.packages("afex")
install.packages("emmeans")
library(here)
library(afex)
library(emmeans)

afex_options(emmeans_model = "multivariate")

data <- read.csv(here("/Users/roggeokk/Documents/GitHub/PSY2R/resources/BIRD.csv"))

library(tidyverse)
data_long <- data %>%
  pivot_longer(
    cols = 3:5,
    names_to = "Spacing",
    values_to = "Yield")%>%
  dplyr::select(subj,Group,Spacing,Yield)

a1<- aov_ez("subj","Yield",data_long, within = "Spacing",between = "Group")
class(a1)

library(knitr)
knitr::kable(nice(a1))

#contrasts
m3 <- emmeans(a1,c("Group","Spacing"))

class(a1) #a1 class is afex_aov

#The goal of the first part of emmsmean code is to convert the object a1 to emmGrid

library(chk)

#CODE LINE IN emmeans # object = .chk.list(object, ...)#could not find .chk.list the best I could find was chk_list

object <-chk_list(a1) #returns same value because a1 is a list so there's no need to change anything 
#if it is not a list it will throw an error and not run!


class(object) #keeps the same format

#CODE LINE IN emmeans # args = .zap.args(object = object, ..., omit = "submodel")

#.zap.args is a function that return a list and omit's submodel. 
#It nestles the list to be inside of one list

#Here is the function from emmeans github to run here
.zap.args = function(..., omit) {
  args = list(...)
  args[!is.na(pmatch(names(args), omit))] = NULL
  args
}

#Here is the line of code that I am running with the object that transforms it to args
args = .zap.args(object = object, omit = "submodel")
# args adds the object into the list that has the object inside


#CODE LINE IN emmeans # 
# if (is.null(args$wt.nuis)) 
 # args$wt.nuis = ifelse(!missing(weights) && is.character(weights), 
                        #weights, "equal")

is.null(args$wt.nuis) # This is true so it does not do the ifelse statement which changes the missing weights with equal

object = do.call(ref_grid, args) # This line finally makes it to emmGrid!



