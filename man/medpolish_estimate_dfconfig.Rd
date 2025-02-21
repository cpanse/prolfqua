% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidyMS_aggregation.R
\name{medpolish_estimate_dfconfig}
\alias{medpolish_estimate_dfconfig}
\title{Median polish estimates of e.g. protein abundances for entire data.frame}
\usage{
medpolish_estimate_dfconfig(pdata, config, name = FALSE)
}
\arguments{
\item{pdata}{data.frame}

\item{config}{AnalysisConfiguration}
}
\description{
Median polish estimates of e.g. protein abundances for entire data.frame
}
\examples{

bb <- prolfqua_data('data_ionstar')$filtered()
bb$config <- old2new(bb$config)
stopifnot(nrow(bb$data) == 25780)
conf <- bb$config
data <- bb$data
conf$table$hierarchyDepth = 1
xnested <- data |>
  dplyr::group_by_at(conf$table$hierarchy_keys_depth()) |> tidyr::nest()

feature <- setdiff(conf$table$hierarchy_keys(),  conf$table$hierarchy_keys_depth())
x <- xnested$data[[1]]
bb <- medpolish_estimate_dfconfig(x,conf)
prolfqua:::.reestablish_condition(x,bb, conf)

}
\seealso{
\code{\link{medpolish_estimate_df}}

Other aggregation: 
\code{\link{INTERNAL_FUNCTIONS_BY_FAMILY}},
\code{\link{aggregate_intensity_topN}()},
\code{\link{estimate_intensity}()},
\code{\link{intensity_summary_by_hkeys}()},
\code{\link{medpolish_estimate_df}()},
\code{\link{medpolish_estimate}()},
\code{\link{medpolish_protein_estimates}()},
\code{\link{plot_estimate}()},
\code{\link{plot_hierarchies_add_quantline}()},
\code{\link{plot_hierarchies_line_df}()},
\code{\link{plot_hierarchies_line}()},
\code{\link{rlm_estimate_dfconfig}()},
\code{\link{rlm_estimate}()}
}
\concept{aggregation}
\keyword{internal}
