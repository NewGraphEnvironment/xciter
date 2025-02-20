# Function to clean a BibTeX file to keep only cited entries.  Also returns a list of citation keys that are
# passed to the function but not included in the bib file so follow up can be done to determine thier
# correct keys (if present in the BibTex file)

#' @inheritParams xct_keys_to_inline
#' @export

xct_bib_clean <- function(path_bib, keys, output_file) {
  fs::file_create(output_file)
  # Read the entire BibTeX file
  lines <- readLines(path_bib)

  # Initialize variables
  keep_entry <- FALSE
  cleaned_lines <- c()

  for (line in lines) {
    # Check if the line starts a new citation entry
    if (grepl("^@", line)) {
      # Extract the citation key
      citation_key <- sub("^@.*\\{([^,]+),.*", "\\1", line)

      # Determine if the entry should be kept
      keep_entry <- citation_key %in% keys
    }

    # Add the line to cleaned_lines if the entry is to be kept
    if (keep_entry) {
      cleaned_lines <- c(cleaned_lines, line)
    }
  }

  # Write the cleaned lines to the output file
  writeLines(cleaned_lines, output_file)

  cat("Cleaned BibTeX file created:", output_file, "\n")
}


#' Check for Missing Citation Keys in a BibTeX File
#'
#' This function identifies citation keys provided in a list that are missing from
#' a specified BibTeX file. It ensures the BibTeX file exists and processes the
#' file to match the citation keys.
#' @inheritParams xct_keys_to_inline
#' @param keys [character] A vector of citation keys to check for in the BibTeX file.
#'
#' @importFrom cli cli_alert_success cli_alert_warning
#' @importFrom chk chk_file chk_string chk_character
#' @family cite
#' @export
#' @rdname xct_bib_clean
#'
#' @return A vector of citation keys missing from the BibTeX file. Returns an empty
#'   vector if all citation keys are found.
#' @examples
#' \dontrun{
#' path_bib <- system.file("extdata", "references.bib", package = "xciter")
#' citations <- c("Smith2020", "Jones2019")
#' xct_bib_keys_missing(path_bib, citations)
#' }
xct_bib_keys_missing <- function(path_bib, citations) {
  # Validate inputs
  chk::chk_string(path_bib)
  chk::chk_file(path_bib)
  chk::chk_character(citations)


  keys_bib <- sort( #sort to ease debugging
    xct_bib_keys_extract(path_bib)
  )



  # Clean input citations by removing leading '@' if present
  clean_citations <- sub("^@", "", citations)

  # Identify missing citations
  missing_citations <- setdiff(clean_citations, keys_bib)

  # Output messages using cli
  if (length(missing_citations) > 0) {
    cli::cli_alert_warning("The following citations were not found in the BibTeX file:")
    print(missing_citations)
  } else {
    cli::cli_alert_success("All specified citations were found in the BibTeX file.")
  }

  # Return the missing citations
  return(missing_citations)
}

#' Extract Citation Keys from a BibTeX File
#'
#' This function extracts all citation keys from a given BibTeX file.
#'
#' @inheritParams xct_keys_to_inline
#' @return A character vector of citation keys extracted from the BibTeX file.
#' @importFrom chk chk_file
#' @rdname xct_bib_clean
#' @export
xct_bib_keys_extract <- function(path_bib) {
  # Validate the input file
  chk::chk_file(path_bib)

  # Read the contents of the BibTeX file
  bib_raw <- readLines(path_bib, warn = FALSE)

  # Extract lines that start with "@" (indicating a BibTeX entry)
  bib_keys_raw <- bib_raw[grepl("^@", bib_raw)]

  # Extract the citation keys from the BibTeX entries
  keys_bib <- sub("^@.*\\{([^,]+),.*", "\\1", bib_keys_raw)

  return(keys_bib)
}


#' Guess Matching Citation Keys for Missing Entries
#'
#' This function attempts to find the closest matching citation keys for keys
#' that are missing from a BibTeX file, based on string distance. Users can set
#' a threshold for the maximum allowable distance for a match, optionally
#' exclude rows where no matches are close enough, and choose the string
#' distance calculation method.
#'
#' @param keys_missing [character] A vector of citation keys that are missing from the BibTeX file.
#'   Typically obtained using [xct_bib_keys_missing()].
#' @param keys_bib [character] A vector of citation keys extracted from the BibTeX file.
#'   Typically obtained using [xct_bib_keys_extract()].
#' @param stringdist_threshold [numeric] The maximum allowable string distance for a match to be considered valid.
#'   This value is passed to `[stringdist::stringdist()]` for the specified method. Distances are non-negative numeric values
#'   where smaller values indicate greater similarity. For short strings (5-10 characters), use `1-3`; for medium strings
#'   (10-20 characters), use `3-7`; and for longer strings (>20 characters), use `7-15`. Default is `15`. Interestingly,
#'   we see some accurate matches at 25 however we also get mismatches when we go this high which could result in
#'   incorrect citations if we find replace those!!
#' @param stringdist_method [character] The method used by `[stringdist::stringdist()]` to calculate string distances.
#'   Options include "osa" (Optimal String Alignment, default), "lv" (Levenshtein), "dl" (Damerau-Levenshtein), "jw" (Jaro-Winkler),
#'   and others. See `[stringdist::stringdist()]` documentation for details. Default is "dl".
#' @param no_match_rows_include [logical] Whether to include rows for keys with no valid matches in the output.
#'   Default is `FALSE`, which excludes such rows.
#'
#' @inheritParams xct_keys_to_inline
#' @return A data frame with two columns:
#'   \describe{
#'     \item{key_missing}{The missing citation keys.}
#'     \item{key_missing_guess_match}{The guessed closest matching citation keys (or `NA` if no valid match is found).}
#'   }
#'   If `no_match_rows_include = FALSE`, rows with no valid matches are excluded.
#'
#' @importFrom stringdist stringdist
#' @importFrom cli cli_alert_warning cli_alert_success
#' @importFrom chk chk_character chk_number chk_string chk_flag
#' @rdname xct_bib_clean
#' @export
#' @seealso [xct_bib_keys_missing()], [xct_bib_keys_extract()], [stringdist::stringdist()]
#'
#' @examples
#' # Path to the example BibTeX file
#' path_bib <- system.file("extdata", "references.bib", package = "xciter")
#'
#' # Define the citation keys to check
#' keys <- c("busch_etal2011LandscapeLevelModel",
#'           "kirsch_etal2014Fishinventoryb",
#'           "test2001")
#'
#' # Extract keys from the BibTeX file
#' keys_bib <- xct_bib_keys_extract(path_bib)
#'
#' # Identify missing keys
#' keys_missing <- xct_bib_keys_missing(path_bib, keys)
#'
#' # Guess matches for missing keys with a string distance threshold and method
#' xct_keys_guess_match(keys_missing, keys_bib)
xct_keys_guess_match <- function(keys_missing, keys_bib, stringdist_threshold = 15,
                                 stringdist_method = "dl", no_match_rows_include = FALSE) {
  # Initialize results
  result <- list(key_missing = character(0), key_missing_guess_match = character(0))
  unmatched_keys <- character(0)

  for (key in keys_missing) {
    distances <- stringdist::stringdist(key, keys_bib, method = stringdist_method)
    closest_index <- which.min(distances)
    closest_distance <- distances[closest_index]
    closest_match <- ifelse(closest_distance <= stringdist_threshold, keys_bib[closest_index], NA_character_)

    if (is.na(closest_match)) {
      unmatched_keys <- c(unmatched_keys, key)
    }

    result$key_missing <- c(result$key_missing, key)
    result$key_missing_guess_match <- c(result$key_missing_guess_match, closest_match)
  }

  if (length(unmatched_keys) > 0) {
    cli::cli_alert_warning(
      paste("No valid match found for the following keys (closest distance exceeds",
            stringdist_threshold, "):", paste(unmatched_keys, collapse = ", "))
    )
  }

  result_df <- data.frame(key_missing = result$key_missing,
                          key_missing_guess_match = result$key_missing_guess_match,
                          stringsAsFactors = FALSE)

  if (!no_match_rows_include) {
    result_df <- result_df[!is.na(result_df$key_missing_guess_match), ]
  }

  return(result_df)
}


















