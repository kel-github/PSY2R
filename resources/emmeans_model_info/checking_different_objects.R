#Here I will be checking if different stat models do the same thing with the object function

#Here I make my line by line code into a function see emmeans_run_line_by_line.R for detail of how I tested this function
library(chk)

generate_emmGrid <- function(object) {
  object <-chk_list(object) 
  
  .zap.args = function(..., omit) {
    args = list(...)
    args[!is.na(pmatch(names(args), omit))] = NULL
    args
  }
  
  args = .zap.args(object = object, omit = "submodel")
  
  is.null(args$wt.nuis) #null is true so 
  
  object = do.call(ref_grid, args) }

#Here we will test aov

#Running a tutorial to do a test aov (one way anova)
my_data <- PlantGrowth

my_data$group <- ordered(my_data$group,
                         levels = c("ctrl", "trt1", "trt2"))

res.aov <- aov(weight ~ group, data = my_data) #This is a list so it will go through the original code

#running the previous code with res.aov as my input and it successfully changed the object to emmGrid
res.aov_after <-generate_emmGrid(res.aov)

#Running each line of code to see if it does the same things before

object <-chk_list(res.aov) 

.zap.args = function(..., omit) {
  args = list(...)
  args[!is.na(pmatch(names(args), omit))] = NULL
  args
}

args = .zap.args(object = object, omit = "submodel")

is.null(args$wt.nuis) #null is true so 

object = do.call(ref_grid, args) 

###res.aov ran the same as the aov_es



#RUNNING THE CODE TO TEST lm
# sample data frame 
df <- data.frame( x= c(1,2,3,4,5), 
                  y= c(1,5,8,15,26)) 

# fit linear model 
linear_model <- lm(y ~ x^2, data=df) 
#test my previous code with linear model
linear_model_after <- generate_emmGrid(linear_model)

object <-chk_list(linear_model) 

args = .zap.args(object = object, omit = "submodel")

is.null(args$wt.nuis) #null is true so 

object = do.call(ref_grid, args) 

###ran with no issue did the same things

#RUNNING the code to test lmer
library(lme4)
data(sleepstudy)
model <- lmer(Reaction ~ Days + (1 | Subject),
              data = sleepstudy)
class(model) #the class was not list but lmerTest and it still worked with my code
model_after <- generate_emmGrid(model)
#It did have an issue but this version is not accepted in emmeans? Maybe because it does not recognize it is a list

object <-chk_list(model) #This part made an error because chk_list did not recognize the model as a list


#RUNNING the code to test on lm
data(bdf, package = "nlme")
fm <- lme(langPOST ~ IQ.ver.cen + avg.IQ.ver.cen, data = bdf,
          random = ~ IQ.ver.cen | schoolNR)
class(fm) #class was lme
fm_after<- generate_emmGrid(fm)
#Code ran with no errors and converted it to emmGrid
object <-chk_list(fm) 

args = .zap.args(object = object, omit = "submodel")

is.null(args$wt.nuis) #null is true 

object = do.call(ref_grid, args) 




