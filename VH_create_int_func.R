#' Create contrasts for interaction effects
#'
#' This function takes the contrasts for each factor and generates an interaction
#' contrast for use in emmeans
#'
#' @param factor_all_con a list of length k, where k corresponds to the number
#' of factors in the model. For each factor, supply a list of contrasts of
#' interest comparing levels within that factor
#'
#' @return a list of interaction contrasts based on the contrasts of interest
#' supplied, to be used with emmeans
#'
#' @export
#'
#' @examples
#' # e.g. inspired by the iris dataset
#' factor1_con <- list(
#' "setosa_vs_versicolor" = c(0.5, -0.5, 0),
#' "versicolor_vs_virginia" = c(0, 0.5, -0.5)
#' )
#' factor2_con <- list(
#'   "sl_vs_sw" = c(0.5, -0.5, 0, 0),
#'   "sl_vs_pl" = c(0.5, 0, -0.5, 0)
#' )
#' cont_example <- list(factor1_con, factor2_con)
#' create_int_func(factor_all_con = cont_example)

create_int_func <- function(factor_all_con){

  nfactor <- length(factor_all_con)
  levels_factor <- rep(NA, nfactor)

  for(i in 1:nfactor){

    levels_factor[i] <- length(factor_all_con[[i]][[1]])

  }

  factor_full <- list()
  factor_idx <- 1:nfactor

  for(i in 1:nfactor){

    factor_con_list <- factor_all_con[[i]]

    if(i == 1){

      repeat_levels <- levels_factor[i != factor_idx]
      neach <- 1
      ntimes <- prod(repeat_levels)

    }else if(i == nfactor){

      repeat_levels <- levels_factor[i != factor_idx]
      neach = prod(repeat_levels)
      ntimes = 1

    }else{

      neach_levels <- levels_factor[i > factor_idx]
      ntimes_levels <- levels_factor[i < factor_idx]
      neach = prod(neach_levels)
      ntimes = prod(ntimes_levels)

    }

    factor_con_full <- lapply(factor_con_list, function(x) rep(rep(x, each = neach), times = ntimes))
    factor_full[[i]] <- factor_con_full

  }

  j = 1
  int_conts <- factor_full[[1]]

  while(j < nfactor){

    int_conts <- lapply(int_conts, function(x) lapply(factor_full[[j+1]], function(y) x*y))
    int_conts <- unlist(int_conts, recursive = FALSE)

    j <- j + 1

  }

  return(int_conts)

}

