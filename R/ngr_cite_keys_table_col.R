#' Transform Citation Keys in a Data Frame Column
#'
#' This function applies the \link{ngr_cite_keys_to_inline} transformation to a specified column
#' in a data frame. It validates the inputs, checks that the specified column exists in the
#' data frame, and replaces its contents with the transformed values.
#'
#' @param dat A data frame containing the column to transform.
#' @param col_format A string specifying the name of the column to transform.
#' @param bib_file A file path to the bibliography file (`.bib`) used for citation keys.
#'   Defaults to `"references.bib"` in the current working directory.
#' @return A data frame with the specified column transformed.
#' @family cite
#' @importFrom chk chk_data chk_string
#' @importFrom cli cli_abort
#' @examples
#' # Example data frame
#' df <- data.frame(
#'   id = 1:3,
#'   bib_keys = c("key1", "key2", "key3")
#' )
#'
#' # Apply the transformation
#' result <- ngr_cite_keys_table_col(df, col_format = "bib_keys")

#' @export
ngr_cite_keys_table_col <- function(dat = NULL, col_format = NULL, bib_file = "references.bib") {
  # Validate inputs
  chk::chk_data(dat)
  chk::chk_string(col_format)

  # Check if col_format exists in the data frame
  if (!col_format %in% names(dat)) {
    cli::cli_abort("The column '{col_format}' is not present in the provided data frame.")
  }

  # Transform the specified column
  dat[[col_format]] <- sapply(dat[[col_format]], function(x) ngr_cite_keys_to_inline(x, bib_file = bib_file))
  dat
}
