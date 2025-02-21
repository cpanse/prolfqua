% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tidyMS_missigness.R
\name{missigness_impute_factors_interactions}
\alias{missigness_impute_factors_interactions}
\title{compute per group averages and impute values
should generalize at some stage}
\usage{
missigness_impute_factors_interactions(
  pdata,
  config,
  probs = 0.03,
  value = c("long", "nrReplicates", "nrMeasured", "meanArea", "imputed"),
  add.prefix = FALSE,
  global = TRUE
)
}
\arguments{
\item{pdata}{data.frame}

\item{config}{AnalysisConfiguration}

\item{probs}{quantile to take average from (default 0.1)}

\item{value}{use default}

\item{add.prefix}{use default}
}
\description{
compute per group averages and impute values
should generalize at some stage
}
\examples{

bb <- prolfqua_data('data_ionstar')$filtered()
stopifnot(nrow(bb$data) == 25780)
configur <- old2new(bb$config)
data <- bb$data
xx <- complete_cases(data, configur)

res <- missigness_impute_factors_interactions(xx, configur)
res <- missigness_impute_factors_interactions(xx, configur, value = "imputed")
res <- missigness_impute_factors_interactions(xx, configur, value = "nrMeasured")
long <- missigness_impute_factors_interactions(xx, configur, value = "long")
dim(long)

}
\seealso{
Other imputation: 
\code{\link{UpSet_interaction_missing_stats}()},
\code{\link{UpSet_missing_stats}()},
\code{\link{aggregate_contrast}()},
\code{\link{get_contrast}()},
\code{\link{missigness_histogram}()},
\code{\link{missingness_per_condition_cumsum}()},
\code{\link{missingness_per_condition}()}
}
\concept{imputation}
\keyword{internal}
