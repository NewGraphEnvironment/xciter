#' Convert Citation Keys to Inline References
#'
#' This function processes a block of text containing citation keys (e.g., `@doe2020`)
#' and converts them to inline references using Pandoc. The function supports
#' custom bibliography and CSL (Citation Style Language) files.
#'
#' @param text A character vector containing text with citation keys (e.g., `@doe2020`).
#' @param bib_file A string specifying the path to the bibliography file (e.g., `references.bib`).
#' @param csl_file A string specifying the path to the CSL file (e.g., `apa.csl`). Default is `NULL`,
#'   which uses Pandoc's default citation style.
#' @return A character vector with inline references replacing the citation keys.
#' @importFrom fs file_exists file_delete
#' @importFrom processx run
#' @export
ngr_cite_keys_to_inline <- function(text, bib_file, csl_file = NULL) {
  # Check for Pandoc installation
  if (Sys.which("pandoc") == "") {
    stop("Pandoc is not installed or not found in the system PATH. Please install Pandoc.")
  }

  # Ensure text is a non-empty character vector
  if (!is.character(text) || length(text) == 0) {
    stop("The `text` parameter must be a non-empty character vector.")
  }

  # Ensure bibliography file exists
  if (!fs::file_exists(bib_file)) {
    stop("The specified bibliography file does not exist: ", bib_file)
  }

  # Ensure CSL file exists if provided
  if (!is.null(csl_file) && !fs::file_exists(csl_file)) {
    stop("The specified CSL file does not exist: ", csl_file)
  }

  # Write input text to a temporary file
  input_file <- tempfile(fileext = ".md")
  output_file <- tempfile(fileext = ".md")
  writeLines(text, input_file)

  # Build Pandoc command
  pandoc_command <- c(
    input_file,
    "--from", "markdown",
    "--to", "plain",
    "--bibliography", bib_file,
    "--citeproc",
    "--metadata", "suppress-bibliography=true",
    "-o", output_file
  )

  # Add CSL file option if provided
  if (!is.null(csl_file)) {
    pandoc_command <- c(pandoc_command, "--csl", csl_file)
  }


  # Run Pandoc and capture output
  processx::run("pandoc", pandoc_command, stdout = "", stderr = "")

  # Read back the processed output
  output_text <- readLines(output_file)

  # Sanity check: Ensure non-empty output
  if (length(output_text) == 0) {
    stop("Processed output is empty. Check the input text or bibliography file.")
  }

  # Clean up temporary files
  fs::file_delete(c(input_file, output_file))

  # # Extract only the first line (inline citation)
  # inline_citation <- output_text[1]

  return(output_text)
}
