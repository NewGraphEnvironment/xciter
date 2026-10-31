#' Refresh a report's CITATION.cff for the version being built
#'
#' A report's `CITATION.cff` is the one record its citations come from. Its title and
#' authors are written by hand; this function rewrites only what a build changes, so it
#' can run at the end of every build:
#'
#' * `date-released`, and `date-published` and `year` in `preferred-citation`: the build
#'   date, because the version on the web is the one being dated;
#' * `version`, at both levels: `Version` in `DESCRIPTION`, so a citation names the
#'   version it was made from as well as the date;
#' * `url` and `repository-code`, at both levels;
#' * `doi`, at both levels: `Config/DOI` in `DESCRIPTION`, when the repository is archived
#'   (a Zenodo concept DOI, for example).
#'
#' The refreshed record must pass [cffr::cff_validate()] before it replaces `path`;
#' otherwise nothing is written.
#'
#' @param path [character] Path to the `CITATION.cff` to refresh. It must exist and carry
#'   a `preferred-citation` block.
#' @param report_url [character] The URL the report is served at.
#' @param repo_url [character] The URL of the report's source repository.
#' @param desc [character] Path to the `DESCRIPTION` that holds `Version` and, optionally,
#'   `Config/DOI`.
#' @param today [Date] The date to stamp. Defaults to [Sys.Date()].
#'
#' @return The refreshed record as a list, invisibly.
#' @family cff
#' @export
#'
#' @examples
#' d <- tempfile("report_")
#' dir.create(d)
#' writeLines(c("Package: report", "Version: 0.2.0"), file.path(d, "DESCRIPTION"))
#' writeLines(c(
#'   "cff-version: 1.2.0",
#'   "message: If you use this report, please cite it as below.",
#'   "title: A report",
#'   "authors:",
#'   "- family-names: Irvine",
#'   "  given-names: Allan",
#'   "type: software",
#'   "preferred-citation:",
#'   "  type: report",
#'   "  title: A report",
#'   "  authors:",
#'   "  - family-names: Irvine",
#'   "    given-names: Allan",
#'   "  institution:",
#'   "    name: New Graph Environment Ltd.",
#'   "  year: 2024"
#' ), file.path(d, "CITATION.cff"))
#' xct_cff_refresh(
#'   path = file.path(d, "CITATION.cff"),
#'   report_url = "https://www.example.com/a_report/",
#'   repo_url = "https://github.com/example/a_report",
#'   desc = file.path(d, "DESCRIPTION"),
#'   today = as.Date("2026-10-31")
#' )
#' cat(readLines(file.path(d, "CITATION.cff")), sep = "\n")
xct_cff_refresh <- function(path = "CITATION.cff", report_url, repo_url,
                            desc = "DESCRIPTION", today = Sys.Date()) {
  if (!file.exists(path)) stop(path, " not found", call. = FALSE)
  urls <- list(report_url = if (missing(report_url)) NULL else report_url,
               repo_url = if (missing(repo_url)) NULL else repo_url)
  for (p in names(urls)) {
    v <- urls[[p]]
    if (!is.character(v) || length(v) != 1 || is.na(v) || !nzchar(v)) {
      stop("`", p, "` must be one non-empty string", call. = FALSE)
    }
  }
  if (!inherits(today, "Date") || length(today) != 1 || is.na(today)) {
    stop("`today` must be one Date", call. = FALSE)
  }
  x <- yaml::read_yaml(path)
  pc <- x$`preferred-citation`
  if (!is.list(pc)) stop(path, ": no preferred-citation block", call. = FALSE)

  d <- format(today, "%Y-%m-%d")
  x$`date-released` <- d
  pc$`date-published` <- d
  pc$year <- as.integer(format(today, "%Y"))
  x$url <- pc$url <- urls$report_url
  x$`repository-code` <- pc$`repository-code` <- urls$repo_url
  ver <- unname(read.dcf(desc, fields = "Version")[1, 1])
  if (is.na(ver) || !nzchar(ver)) stop(desc, ": no Version", call. = FALSE)
  x$version <- pc$version <- ver
  doi <- unname(read.dcf(desc, fields = "Config/DOI")[1, 1])
  if (!is.na(doi) && nzchar(doi)) x$doi <- pc$doi <- doi
  x$`preferred-citation` <- pc

  tmp <- tempfile("CITATION_", tmpdir = dirname(path), fileext = ".cff")
  on.exit(unlink(tmp), add = TRUE)
  yaml::write_yaml(x, tmp)
  # cff_validate() reports a problem and returns FALSE rather than erroring
  if (!isTRUE(suppressMessages(cffr::cff_validate(tmp, verbose = FALSE)))) {
    cffr::cff_validate(tmp)
    stop(path, ": the refreshed record does not validate; nothing written", call. = FALSE)
  }
  if (!file.rename(tmp, path)) stop("could not replace ", path, call. = FALSE)
  message(path, " refreshed: version ", ver, " dated ", d,
          if (!is.na(doi) && nzchar(doi)) paste(" with DOI", doi) else " (no DOI)")
  invisible(x)
}

#' Write a bibliography of reports from their own CITATION.cff records
#'
#' A report that cites another report can cite it by that report's own `CITATION.cff`,
#' the one record its citations come from, rather than by a reference-manager entry
#' typed from it. Each repository's record is read from its default branch on GitHub,
#' converted with [cffr::as_bibentry()] using `what = "preferred"` (a `@TechReport`
#' naming the publisher as institution), and keyed by the repository name, so a report
#' is cited as `[@<repo>]`.
#'
#' Any record that cannot be read, does not validate, or gives no report entry with a
#' title and authors stops the call: a bibliography that silently drops an entry would
#' render that citation unresolved with nothing to say why. The file is written
#' atomically.
#'
#' The repositories must be public: no token is sent.
#'
#' @param repos [character] Repository names to cite. An empty vector writes an empty
#'   file.
#' @param path [character] Path of the `.bib` file to write.
#' @param owner [character] The GitHub owner of the repositories.
#'
#' @return `path`, invisibly.
#' @family cff
#' @export
#'
#' @examples
#' \dontrun{
#' xct_bib_from_cff(
#'   c("fish_passage_peace_2024_reporting", "fish_passage_skeena_2024_reporting"),
#'   path = file.path(tempdir(), "references-reports.bib")
#' )
#' }
xct_bib_from_cff <- function(repos, path, owner = "NewGraphEnvironment") {
  repos <- as.character(unlist(repos))
  if (!is.character(path) || length(path) != 1 || is.na(path) || !nzchar(path)) {
    stop("`path` must be one non-empty string", call. = FALSE)
  }
  bad <- repos[is.na(repos) | !grepl("^[A-Za-z0-9._-]+$", repos)]
  if (length(bad)) stop("not a repository name: ", paste(bad, collapse = ", "), call. = FALSE)
  if (anyDuplicated(repos)) stop("`repos` names a repository twice", call. = FALSE)

  entry <- function(repo) {
    txt <- xct_cff_fetch(owner, repo)
    x <- tryCatch(cffr::as_cff(yaml::yaml.load(txt)), error = function(e) e)
    if (inherits(x, "error") || !isTRUE(suppressMessages(cffr::cff_validate(x, verbose = FALSE)))) {
      stop(repo, ": CITATION.cff is not a valid citation record", call. = FALSE)
    }
    b <- suppressMessages(cffr::as_bibentry(x, what = "preferred"))
    # as_bibentry() gives one empty @Misc, not an error, for a record it cannot convert,
    # and the software @Misc for one with no preferred-citation: so check what was built
    e <- unclass(b)
    if (length(e) != 1 || !identical(attr(e[[1]], "bibtype"), "TechReport") ||
        !length(b$title) || !nzchar(b$title) || !length(b$author)) {
      stop(repo, ": CITATION.cff gave no report entry (type: report in preferred-citation, ",
           "with title and authors)", call. = FALSE)
    }
    b$key <- repo
    paste(utils::toBibtex(b), collapse = "\n")
  }
  text <- paste(vapply(repos, entry, character(1)), collapse = "\n\n")
  if (length(repos)) text <- paste0(text, "\n")

  tmp <- tempfile("bib_", tmpdir = dirname(path), fileext = ".bib")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(text, tmp, sep = "")
  if (!file.rename(tmp, path)) stop("could not replace ", path, call. = FALSE)
  message(path, " written: ", length(repos), " report(s)")
  invisible(path)
}

# Read one repository's CITATION.cff from its default branch. The only network call in
# xct_bib_from_cff(), so tests replace it.
xct_cff_fetch <- function(owner, repo) {
  url <- sprintf("https://raw.githubusercontent.com/%s/%s/HEAD/CITATION.cff", owner, repo)
  h <- curl::new_handle(useragent = "xciter", timeout = 60)
  r <- tryCatch(curl::curl_fetch_memory(url, handle = h), error = function(e) e)
  if (inherits(r, "error")) stop(repo, ": reading CITATION.cff failed: ", conditionMessage(r), call. = FALSE)
  if (r$status_code != 200) stop(repo, ": CITATION.cff answered HTTP ", r$status_code, call. = FALSE)
  rawToChar(r$content)
}
