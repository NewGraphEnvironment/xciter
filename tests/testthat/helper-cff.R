# A report CITATION.cff in the shape xct_cff_refresh() and xct_bib_from_cff() expect.
cff_report_lines <- function(title = "A report", year = 2024) {
  c(
    "cff-version: 1.2.0",
    "message: If you use this report, please cite it as below.",
    paste0("title: ", title),
    "authors:",
    "- family-names: Irvine",
    "  given-names: Allan",
    "- family-names: Schick",
    "  given-names: Lucy",
    "type: software",
    "preferred-citation:",
    "  type: report",
    paste0("  title: ", title),
    "  authors:",
    "  - family-names: Irvine",
    "    given-names: Allan",
    "  - family-names: Schick",
    "    given-names: Lucy",
    "  institution:",
    "    name: New Graph Environment Ltd.",
    paste0("  year: ", year)
  )
}

# A report directory holding CITATION.cff and DESCRIPTION.
local_report <- function(version = "0.2.0", doi = NULL, cff = cff_report_lines(), env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  writeLines(c("Package: report", if (!is.null(version)) paste0("Version: ", version),
               if (!is.null(doi)) paste0("Config/DOI: ", doi)), file.path(d, "DESCRIPTION"))
  writeLines(cff, file.path(d, "CITATION.cff"))
  d
}

# Replace the network read of a CITATION.cff. A repository with no fixture fails the way
# an unreachable network would, so no test reaches GitHub.
local_cff_fetch <- function(records = list(), env = parent.frame()) {
  testthat::local_mocked_bindings(
    xct_cff_fetch = function(owner, repo) {
      if (is.null(records[[repo]])) stop(repo, ": network called in a test", call. = FALSE)
      paste(records[[repo]], collapse = "\n")
    },
    .env = env
  )
}
