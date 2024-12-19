#' @title xciter: Tools for working with and citing references.
#'
#' @description
#' The \pkg{xciter} package provides utilities for working with references
#' and inline citations. It also alows access to an exported bib file
#' from the NewGraphEnvironment shared Zotero library. It aims to streamline the
#' integration of citation data into reproducible research workflows, making it
#' easier to:
#'
#' - Identify all citation keys in documents and confirm their presence in a specified .bib file.
#' - Highlight citation keys that do not match and suggest the closest matching keys from the .bib file.
#' - Provide workarounds for citation handling in interactive tables (DT) and other HTML outputs where standard citation rendering in R Markdown and Quarto may fail.
#'
#' @section Zotero Export:
#' The file \code{NewGraphEnvironment.bib}, available at:
#'
#' \code{system.file("extdata", "NewGraphEnvironment.bib", package = "xciter")},
#'
#' is an export of the entire NewGraphEnvironment shared Zotero library. To find
#' out when it was last updated, please refer to the
#' [GitHub repository](https://github.com/NewGraphEnvironment/xciter) and review
#' the commit history. The commit date associated with the update of this file
#' reflects its freshness.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

