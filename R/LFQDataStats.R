# LFQDataStats-----
#'
#' Decorates LFQData with methods to compute statistics of interactions
#'
#' compute stdv, mean and CV per peptide or protein and condition.
#'
#' @export
#' @family LFQData
#' @examples
#'
#' # study variance of not normalized data
#' #source("c:/Users/wewol/prog/prolfqua/R/LFQData.R")
#' runallfuncs <- function(x){
#'
#'   stopifnot("data.frame" %in% class(x$stats()))
#'   stopifnot(c("long", "wide") %in% names(x$stats_quantiles()))
#'   stopifnot("ggplot" %in% class(x$density()))
#'   stopifnot("ggplot" %in% class(x$density_median()))
#'   stopifnot("ggplot" %in% class(x$density("ecdf")))
#'   stopifnot("ggplot" %in% class(x$density_median("ecdf")))
#'   stopifnot("ggplot" %in% class(x$violin()))
#'   stopifnot("ggplot" %in% class(x$violin_median()))
#'   stopifnot("ggplot" %in% class(x$stdv_vs_mean(size = 400)))
#'   if(!x$lfq$is_transformed()){
#'     stopifnot(is.null(x$power_t_test()))
#'     stopifnot(is.null(x$power_t_test_quantiles()))
#'   }
#' }
#' istar <- prolfqua_data('data_ionstar')$filtered()
#' istar$config <- old2new(istar$config)
#' data <- istar$data |> dplyr::filter(protein_Id %in% sample(protein_Id, 100))
#' lfqdata <- LFQData$new(data, istar$config)
#' lfqstats <- lfqdata$get_Stats()
#' lfqstats$violin()
#' runallfuncs(lfqstats)
#' x<-lfqstats
#'
#' #study variance of normalized data
#'
#' istar <- prolfqua_data('data_ionstar')$normalized()
#' istar$config <- old2new(istar$config)
#' istar$config$table$is_response_transformed
#' data <- istar$data |> dplyr::filter(protein_Id %in% sample(protein_Id, 100))
#' lfqdata <- LFQData$new(data, istar$config)
#' lfqdata$is_transformed(TRUE)
#' lfqstats <- lfqdata$get_Stats()
#' runallfuncs(lfqstats)
#'
#' #Slightly different dataset
#'
#' bb <- prolfqua_data('data_ionstar')$filtered()
#' bb$config <- old2new(bb$config)
#' stopifnot(nrow(bb$data) == 25780)
#' config <- bb$config$clone(deep = TRUE)
#' analysis <- bb$data
#'
#' lfqdata <- LFQData$new(analysis, config)
#' # estimates statistics for all samples
#' lfqstats <- lfqdata$get_Stats(stats = "all")
#' runallfuncs(lfqstats)
#' lfqstats <- lfqdata$get_Stats(stats = "everything")
#' runallfuncs(lfqstats)
LFQDataStats <- R6::R6Class(
  "LFQDataStats",
  public = list(
    #' @field lfq LFQData
    lfq = NULL,
    #' @field stat either CV or sd (if is_transformed)
    stat = "CV",
    #' @field statsdf frame with statistics.
    statsdf = NULL,
    #' @description
    #' create analyse variances and CV
    #' @param lfqdata LFQData object
    #' @param stats if interaction - within group stats, if all then overall CV, if pooled - then pooled variance using grouping information (t.b.d.)
    initialize = function(lfqdata, stats = c("everything", "interaction", "all")){
      stats <- match.arg(stats)
      self$lfq = lfqdata
      self$stat <- if (!self$lfq$is_transformed()) {"CV"} else {"sd"}
      if (stats == "interaction" ) {
        self$statsdf <- prolfqua::summarize_stats(self$lfq$data, self$lfq$config)
      } else if (stats == "all" ) {
        self$statsdf <-
          prolfqua::summarize_stats_all(self$lfq$data, self$lfq$config)
      } else if (stats == "everything" ) {

        self$statsdf <- bind_rows(
          prolfqua::summarize_stats(self$lfq$data, self$lfq$config),
          prolfqua::summarize_stats_all(self$lfq$data, self$lfq$config)
        )
      }
    },
    #' @description
    #' access data.frame with statistics
    #' @return data.frame with computed statistics
    stats = function(){
      self$statsdf
    },
    #' @description
    #' Determine CV or sd for the quantiles
    #' @param probs for which quantile to determine CV or sd
    stats_quantiles = function(probs = c(0.1, 0.25, 0.5, 0.75, 0.9)){
      res <- prolfqua::summarize_stats_quantiles(
        self$stats(),
        self$lfq$config,
        stats = self$stat,
        probs = probs)
      return(res)
    },
    #' @description
    #' plots density or ecdf
    #' @param ggstat either density or ecdf
    #' @return ggplot
    density = function(ggstat = c("density", "ecdf")){
      prolfqua::plot_stat_density(
        self$stats(),
        self$lfq$config,
        stat = self$stat,
        ggstat = ggstat)
    },
    #' @description
    #' plot density or ecdf of CV or sd for the 50% of low intensity data and 50% of high intensity data
    #' @param ggstat either density of ecdf
    #' @return ggplot
    density_median = function(ggstat = c("density", "ecdf")){
      prolfqua::plot_stat_density_median(
        self$stats(),
        self$lfq$config,
        stat = self$stat,
        ggstat = ggstat)
    },
    #' @description
    #' plot violinplot of CV or sd
    #' @param ggstat either density of ecdf
    #' @return ggplot
    violin = function(){
      prolfqua::plot_stat_violin(self$stats(), self$lfq$config, stat = self$stat)
    },
    #' @description
    #' plot violinplot of CV or sd for the 50% of low intensity data and 50% of high intensity data
    #'
    #' @return ggplot
    #'
    violin_median = function(){
      prolfqua::plot_stat_violin_median(self$stats(), self$lfq$config, stat = self$stat)
    },
    #' @description
    #' plot sd vs mean
    #' @param size number of points to sample (default 200)
    #' @return ggplot
    #'
    stdv_vs_mean = function(size= 200){
      prolfqua::plot_stdv_vs_mean(self$stats(), self$lfq$config, size = size)
    },
    #' @description
    #' compute sample size for entire dataset
    #' @param probs quantiles of sd for which sample size should be computed
    #' @param delta effect size
    #' @param power power of test
    #' @param sig.level significance level.
    power_t_test_quantiles = function(
    probs = c(0.1, 0.25, 0.5, 0.75, 0.9),
    delta = c(0.59,1,2),
    power = 0.8,
    sig.level = 0.05)
    {
      if (!self$lfq$is_transformed()) {
        warning("data is not transformed - aborting")
        return()
      }
      res <- self$stats_quantiles(probs)
      res <- lfq_power_t_test_quantiles_V2(res$long,
                                           delta = delta,
                                           power = power,
                                           sig.level = sig.level )
      return(res)
    },
    #' @description
    #' compute sample for each protein
    #' @param delta effect size
    #' @param power power of test
    #' @param sig.level significance level.
    power_t_test = function(
    delta = c(0.59,1,2),
    power = 0.8,
    sig.level = 0.05
    ){
      if (!self$lfq$is_transformed()) {
        warning("data is not transformed - aborting")
        return()
      }

      res <- prolfqua::lfq_power_t_test_proteins(self$stats(),
                                                 delta = delta,
                                                 power = power,
                                                 sig.level = sig.level,
                                                 min.n = 1.5)
      return(res)
    }
  )
)
