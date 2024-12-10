#' Extract Citations from Text
#'
#' This function extracts citations in the form of `@citation` or `[e.g., @citation1; @citation2]`
#' from a given text. Additional citations can also be included via a parameter.
#'
#' @param text A character string containing the text to process. Passing `NA` will issue a warning.
#' @param citations_additional A character vector of additional citations to include. Default is `NULL`.
#' @return A character vector of unique citation keys.
#' @importFrom stringr str_extract_all
#' @importFrom cli cli_warn
#' @importFrom chk chk_string chk_character
#' @family cite
#' @export
ngr_cite_keys_extract <- function(text, citations_additional = NULL) {
  # Validate `text` input
  chk::chk_string(text) # Ensures text is a single string

  if (is.na(text)) {
    cli::cli_warn("`text` is NA. No citations will be extracted from the text.")
    text <- ""
  }

  # Validate `citations_additional`
  if (!is.null(citations_additional)) {
    chk::chk_character(citations_additional) # Ensures it is a character vector
  } else {
    citations_additional <- character() # Convert NULL to an empty vector
  }

  # Regular expression to find citations in the text
  citation_pattern <- "@[a-zA-Z0-9_:-]+"

  # Extract citations using stringr
  citations <- stringr::str_extract_all(text, citation_pattern)[[1]]

  # Remove the leading '@' from the citations and ensure uniqueness
  citations <- unique(sub("^@", "", citations))

  # Combine with additional citations and ensure uniqueness
  all_citations <- unique(c(citations, citations_additional))

  return(all_citations)
}


#' Extract Citation Keys from a Data Frame Column
#'
#' This function extracts citation keys from a specified column in a data frame
#' and optinally formats them as a character vector or prints them row-wise for easy copy-pasting
#' into the `nocite` line of YAML in an R Markdown document.  This can be handy when we are using
#' [ngr_cite_keys_extract()] to format a table column for reporting but we
#' require the citation keys so that they show up in the references section of the overall report.
#'
#' This function builds on /link{ngr_cite_keys_extract}, and integrates its functionality
#' for working with citation keys extracted from a data frame.
#'
#' @inheritParams ngr_cite_keys_to_inline_table_col
#' @param print_rowwise Logical. If `TRUE`, formats and prints keys row-wise with a trailing
#'   comma for easy YAML compatibility. Defaults to `TRUE`.
#' @return A character vector of citation keys extracted from a data frame column.
#' @importFrom chk chk_data chk_string chk_logical
#' @seealso [ngr_cite_keys_extract()]
#' @rdname ngr_cite_keys_extract
#' @export
ngr_cite_keys_extract_table <- function(dat, col_format, print_rowwise = TRUE, ...) {
  chk::chk_data(dat)
  chk::chk_string(col_format)
  chk::chk_logical(print_rowwise)

  # Extract the column and collapse it into a single string
  result <- ngr_cite_keys_extract(paste(dat[[col_format]], collapse = ", "), ...)

  if (print_rowwise) {
    # Split the result by commas and print each item on a new line
    items <- unlist(strsplit(result, ", "))
    cat(items, sep = ",\n")
    return(invisible(result)) # Return result invisibly if printing
  }

  return(result)
}



