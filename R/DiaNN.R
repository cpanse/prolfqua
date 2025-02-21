#' read DiaNN diann-output.tsv file
#'
#' filter for 2 peptides per protein, and for Q.Value < 0.01 (default)
#'
#' @export
#'
diann_read_output <- function(path, nrPeptides = 2, Q.Value = 0.01){
  add_nr_pep <- function(report){
    nrPEP <- report |>
      dplyr::select(all_of(c("Protein.Group", "Stripped.Sequence"))) |>
      dplyr::distinct() |>
      dplyr::group_by(across("Protein.Group")) |>
      dplyr::summarize(nrPeptides = dplyr::n())
    report <- dplyr::inner_join(report, nrPEP)
    return(list(nrPEP = nrPEP, report = report))
  }

  select_PG <- function(report){
    columns  <- c("File.Name",
                  "Protein.Group",
                  "Protein.Names",
                  "PG.Quantity",
                  "PG.MaxLFQ",
                  "PG.Q.Value",
                  "Global.PG.Q.Value",
                  "Lib.PG.Q.Value",
                  "nrPeptides")
    columns %in% names(report)

    PG <- report |> dplyr::select( dplyr::all_of( columns )) |>
      dplyr::distinct() |>
      dplyr::ungroup()
    return(PG)
  }

  filter_PG <- function(PG, nrPeptides_min = 2, Q.Value = 0.01){
    PG <- PG |> dplyr::filter(.data$nrPeptides >= nrPeptides_min)
    PG <- PG |> dplyr::filter(.data$Lib.PG.Q.Value < Q.Value)
    PG <- PG |> dplyr::filter(.data$PG.Q.Value < Q.Value)
  }

  ## use internal functions
  report <- readr::read_tsv(path, show_col_types = FALSE)
  rNR <- add_nr_pep(report)
  PG <- select_PG(rNR$report)
  PG2 <- filter_PG(PG, nrPeptides_min = nrPeptides, Q.Value = Q.Value)
  report2 <- inner_join(PG2, report)
  return(report2)
}

#' Create peptide level (stripped sequences) report by aggregating Precursor abundances.
#'
#' \code{\link{diann_read_output}}
#' @export
#'
diann_output_to_peptide <- function(report2){
  peptide <- report2 |>
  dplyr::group_by(across(c("raw.file",
                           "Protein.Group",
                           "Protein.Names",
                           "PG.Quantity",
                           "nrPeptides",
                           "Stripped.Sequence" ) )) |>
  dplyr::summarize(Peptide.Quantity = sum(.data$Precursor.Quantity, na.rm = TRUE),
                   Peptide.Normalised = sum(.data$Precursor.Normalised, na.rm = TRUE),
                   Peptide.Translated = sum(.data$Precursor.Translated, na.rm = TRUE),
                   Peptide.Ms1.Translated = sum(.data$Ms1.Translated, na.rm = TRUE),
                   PEP = min(.data$PEP, na.rm = TRUE)
                   ,.groups = "drop")
  return(peptide)

}
