#' Format a Single Citation for Inline Text
#'
#' Formats a single citation key into inline text without brackets.
#' @param key The citation key.
#' @param bib_obj The bibliography object created by reading in a .bib file with `RefManageR::ReadBib`.
#' @param key_abort_on_missing Logical. If TRUE, aborts on missing citation keys.
#' @param ... Additional arguments passed from the main function.
#' @importFrom cli cli_abort
#' @family cite
#' @return Formatted citation as a string.
excitr_format_single <- function(key, bib_obj, key_abort_on_missing = TRUE, ...) {

  chk::chk_string(key)
  chk::chk_list(bib_obj)
  chk::chk_flag(key_abort_on_missing)

  # Allow flexibility to override the key_abort_on_missing flag from upstream
  key_abort_on_missing <- key_abort_on_missing
  args <- list(...)
  if (!is.null(args$key_abort_on_missing)) {
    key_abort_on_missing <- args$key_abort_on_missing
  }

  # Remove any outer brackets and '@' symbol from the key
  key <- sub("^\\[(.*)\\]$", "\\1", key)
  key <- trimws(key)
  key <- sub("^@", "", key)

  # Check if the key exists in the bibliography object
  if (key %in% names(bib_obj)) {
    entry <- bib_obj[[key]]
    authors <- entry$author
    last_names <- sapply(authors, function(author) author$family)

    # Extract the year, using date if year is missing
    year <- entry$year
    if (is.null(year) || year == "") {
      year <- format(entry$dateobj, "%Y")
      if (is.na(year) || year == "") {
        warning(paste("Year not found for citation key:", key))
        year <- ""
      }
    }

    # Format author names according to the number of authors
    if (length(last_names) > 2) {
      citation_text <- paste0(last_names[1], " et al.")
    } else if (length(last_names) == 2) {
      citation_text <- paste0(last_names[1], " and ", last_names[2])
    } else if (length(last_names) == 1) {
      citation_text <- last_names[1]
    } else {
      warning(paste("No authors found for citation key:", key))
      citation_text <- "Unknown Author"
    }

    # Return formatted author-year without parentheses for flexibility
    citation_text <- paste0(citation_text, " ", year)

  } else {
    message <- paste("Citation key not found in bibliography:", key)
    if (key_abort_on_missing) {
      cli::cli_abort(message)
    } else {
      warning(message)
      citation_text <- NA
    }
  }
  return(citation_text)
}

#' Format Multiple Citations
#'
#' Formats one or more citation keys into a single inline reference.
#' @param raw_key A raw citation key string, possibly with brackets.
#' @param bib_obj The bibliography object.
#' @param ... Additional arguments passed from the main function.
#' @family cite
#' @return Formatted citation as a string.
excitr_format <- function(raw_key, bib_obj, ...) {
  # Check if raw_key is a multiple citation (enclosed in square brackets)
  if (grepl("^\\[.*\\]$", raw_key)) {
    # Remove the outer brackets from the multiple citation string
    keys_str <- sub("^\\[(.*)\\]$", "\\1", raw_key)
    # Split multiple keys by semicolon and any surrounding whitespace
    keys <- unlist(strsplit(keys_str, ";\\s*"))
    # Remove the '@' symbol from each key, if present
    keys <- sub("^@", "", keys)
    # Format each citation key individually without parentheses for multiple citations
    formatted_citations <- sapply(keys, function(key) {
      excitr_format_single(key, bib_obj, ...)
    })
    # Assemble the formatted citations into a single citation string wrapped in parentheses
    citation <- paste0("(", excitr_assemble(formatted_citations), ")")

    # If the raw_key is a single citation prefixed by '@'
  } else if (grepl("^@.+$", raw_key)) {
    # Remove the '@' symbol from the key
    key <- sub("^@", "", raw_key)
    # Format the single citation key with "Author (Year)" format
    citation <- excitr_format_single(key, bib_obj, ...)
    citation <- sub("(\\d{4})$", "(\\1)", citation)  # Wrap only the year in parentheses

    # If raw_key does not have square brackets or '@', treat it as a basic single key
  } else {
    key <- raw_key
    # Format the citation directly as a single key with "Author (Year)" format
    citation <- excitr_format_single(key, bib_obj, ...)
    citation <- sub("(\\d{4})$", "(\\1)", citation)  # Wrap only the year in parentheses
  }

  # Return the fully formatted citation string
  return(citation)
}




#' Assemble Multiple Citations with APA Formatting
#'
#' Assembles a list of citations into a single inline reference, using semicolons.
#' @param citations A vector of citation strings.
#' @family cite
#' @return A single string with all citations separated by semicolons.
excitr_assemble <- function(citations) {
  citations <- citations[!is.na(citations)]
  if (length(citations) == 0) {
    return("")
  } else {
    # Concatenate citations with a semicolon separator
    return(paste(citations, collapse = "; "))
  }
}

#' Generate Cross-reference Data Frame with Original Keys in One Column and Inline APA-Style Citations in Another.
#'
#' We probably just want to use [excitr_keys_to_inline()] or [excitr_keys_to_inline_table_col()]but this will
#' This function requires the `RefManageR` package. If it is not installed, you can install it with
#' `install.packages("RefManageR")`.
#'
#' This function takes citation keys passed as a list and generates inline APA-style references for each item of the list.
#' @param citation_keys A character vector of citation keys.
#' @param path_bib Path to the .bib bibliography file.
#' @param key_abort_on_missing Logical. If TRUE, aborts on missing citation keys.
#' @param key_check_response Response level for missing fields in bib entries. Default is "warn". Passed to
#' \code{\link[RefManageR]{ReadBib}} in the RefManageR package
#' @family cite
#' @return A data frame with citation keys in one column and their formatted inline references in another.
#' @importFrom RefManageR ReadBib
#' @importFrom chk chk_character chk_string chk_flag
#' @importFrom cli cli_abort
#' @seealso [excitr_keys_to_inline()], [excitr_keys_to_inline_table_col()]
#' @export
#' @examples
#' \dontrun{
#' path_bib <- "path/to/references.bib"
#' citation_keys <- c("@smith2000", "[@smith2001; @doe2005]")
#' excitr_keys_to_xref(citation_keys, path_bib)
#' }
excitr_keys_to_xref <- function(citation_keys, path_bib, key_abort_on_missing = TRUE, key_check_response = "warn") {
  chk::chk_character(citation_keys)
  chk::chk_string(path_bib)
  chk::chk_file(path_bib)
  chk::chk_flag(key_abort_on_missing)

  if (!requireNamespace("RefManageR", quietly = TRUE)) {
    cli::abort("The 'RefManageR' package is required for this function but is not installed. Please install it using install.packages('RefManageR').")
  }

  # Read the bibliography file
  bib_obj <- RefManageR::ReadBib(path_bib, check = key_check_response)

  # Process each citation key through excitr_format
  reference_list <- sapply(citation_keys, function(key) {
    excitr_format(key, bib_obj, key_abort_on_missing = key_abort_on_missing)
  })

  # Create a data.frame to store citation keys and their formatted references
  result <- data.frame(
    citation_key = citation_keys,
    reference_inline = reference_list,
    stringsAsFactors = FALSE,
    row.names = NULL
  )

  return(result)
}

