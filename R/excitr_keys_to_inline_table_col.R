#' Transform Citation Keys in a Data Frame Column
#'
#' This function applies the \link{excitr_keys_to_inline} transformation to a specified column
#' in a data frame. It validates the inputs, checks that the specified column exists in the
#' data frame, and replaces citation keys with inline citations.
#'
#' @param dat A data frame containing the column to transform.
#' @param col_format A string specifying the name of the column to transform.
#' @param path_bib A file path to the bibliography file (`.bib`) used for citation keys.
#'   Defaults to `"references.bib"` in the current working directory.
#' @return A data frame with the specified column transformed.
#' @rdname excitr_keys_to_inline
#' @family cite
#' @importFrom chk chk_data chk_string
#' @importFrom cli cli_abort
#' @examples
#' # Path to a BibTeX file included in the package
#' path_bib <- system.file("extdata", "references.bib", package = "ngr")
#'
#' # Example data frame
#' dat <- data.frame(
#'   id = 1:3,
#'   bib_keys = c(
#'     "Outside block quotes @busch_etal2011LandscapeLevelModela and in [@woll_etal2017SalmonEcological]",
#'     "This is many [@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
#'     "this is a failed key @key3")
#' )
#'
#' # Process the data frame
#' result <- excitr_keys_to_inline_table_col(dat, col_format = "bib_keys", path_bib = path_bib)
#' result
#'

#' @export
excitr_keys_to_inline_table_col <- function(dat = NULL, col_format = NULL, path_bib = "references.bib") {
  # Validate inputs
  chk::chk_data(dat)
  chk::chk_string(col_format)

  # Check if col_format exists in the data frame
  if (!col_format %in% names(dat)) {
    cli::cli_abort("The column '{col_format}' is not present in the provided data frame.")
  }

  # Transform the specified column
  dat[[col_format]] <- sapply(dat[[col_format]], function(x) excitr_keys_to_inline(x, path_bib = path_bib))
  dat
}
