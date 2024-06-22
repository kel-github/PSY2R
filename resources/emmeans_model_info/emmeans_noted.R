install.packages("emmeans")
#lsf.str("package:emmeans")

##HERE is the code from emmeans that works on the object. It sets up the format of the object

function (object, specs, by = NULL, fac.reduce = function(coefs) apply(coefs, 
 2, mean), contr, options = get_emm_option("emmeans"), weights, 
offset, ..., tran) 

{ 
#.chk.list stores the first value in the function as a list of objects it keeps the same values
#it does not change the class
#LINE 1 of the code 
  
  object = .chk.list(object, ...)

# here we check if the object is an emmGrid, emmGrid is a class that we want for the object
  #the ! means if the object is not emmGrid do the next line of code
#LINE 2 of the code # 
  
  if (!is(object, "emmGrid")) {

#.zap.args is a function that runs if the object is not an emmGrid it will omit the submodel
#LINE 3 of code 
    
    args = .zap.args(object = object, ..., omit = "submodel")

#If the variable was a args which removed the submodel previously then we check column wt.nuis to see if it is null
#LINE 4 of code # 
    if (is.null(args$wt.nuis)) 
#we keep the weights if it is not missing
# LINE 5 of code#  
      args$wt.nuis = ifelse(!missing(weights) && is.character(weights), weights, "equal")
#we call the object and use do.call that uses ref_grid to change args into emmsgrid
 object = do.call(ref_grid, args) } 
  }

