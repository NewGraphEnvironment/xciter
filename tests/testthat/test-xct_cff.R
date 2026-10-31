refresh <- function(d, ...) {
  xct_cff_refresh(
    path = file.path(d, "CITATION.cff"),
    report_url = "https://www.example.com/a_report/",
    repo_url = "https://github.com/example/a_report",
    desc = file.path(d, "DESCRIPTION"),
    today = as.Date("2026-10-31"),
    ...
  )
}

test_that("xct_cff_refresh stamps the date, version and URLs at both levels", {
  d <- local_report()
  expect_message(refresh(d), "version 0.2.0 dated 2026-10-31 \\(no DOI\\)")
  x <- yaml::read_yaml(file.path(d, "CITATION.cff"))
  pc <- x$`preferred-citation`
  expect_equal(x$`date-released`, "2026-10-31")
  expect_equal(pc$`date-published`, "2026-10-31")
  expect_identical(pc$year, 2026L)
  expect_identical(x$version, "0.2.0")
  expect_identical(pc$version, "0.2.0")
  expect_equal(c(x$url, pc$url), rep("https://www.example.com/a_report/", 2))
  expect_equal(c(x$`repository-code`, pc$`repository-code`), rep("https://github.com/example/a_report", 2))
  expect_null(x$doi)
  expect_equal(pc$title, "A report")
})

test_that("xct_cff_refresh writes the DOI from Config/DOI", {
  d <- local_report(doi = "10.5281/zenodo.1")
  expect_message(refresh(d), "with DOI 10.5281/zenodo.1")
  x <- yaml::read_yaml(file.path(d, "CITATION.cff"))
  expect_equal(c(x$doi, x$`preferred-citation`$doi), rep("10.5281/zenodo.1", 2))
})

test_that("a version that looks like a number stays a string", {
  d <- local_report(version = "1.0")
  suppressMessages(refresh(d))
  expect_identical(yaml::read_yaml(file.path(d, "CITATION.cff"))$version, "1.0")
})

test_that("running twice gives the same record", {
  d <- local_report()
  suppressMessages(refresh(d))
  first <- readLines(file.path(d, "CITATION.cff"))
  suppressMessages(refresh(d))
  expect_identical(readLines(file.path(d, "CITATION.cff")), first)
})

test_that("a DESCRIPTION with no Version stops and leaves the record alone", {
  d <- local_report(version = NULL)
  before <- readLines(file.path(d, "CITATION.cff"))
  expect_error(refresh(d), "no Version")
  expect_identical(readLines(file.path(d, "CITATION.cff")), before)
})

test_that("a record that will not validate is not written", {
  cff <- cff_report_lines()
  d <- local_report(cff = cff[!grepl("^(authors:|- family|  given-names: (Allan|Lucy)$)", cff)])
  before <- readLines(file.path(d, "CITATION.cff"))
  expect_error(suppressMessages(refresh(d)), "does not validate")
  expect_identical(readLines(file.path(d, "CITATION.cff")), before)
  expect_length(list.files(d, "^CITATION_"), 0)
})

test_that("xct_cff_refresh refuses a missing record, block or URL", {
  d <- local_report()
  expect_error(xct_cff_refresh(file.path(d, "nope.cff"), "u", "r", file.path(d, "DESCRIPTION")), "not found")
  expect_error(xct_cff_refresh(file.path(d, "CITATION.cff"), repo_url = "r", desc = file.path(d, "DESCRIPTION")),
               "`report_url` must be one non-empty string")
  expect_error(xct_cff_refresh(file.path(d, "CITATION.cff"), "", "r", file.path(d, "DESCRIPTION")),
               "`report_url`")
  writeLines(cff_report_lines()[1:9], file.path(d, "CITATION.cff"))
  expect_error(xct_cff_refresh(file.path(d, "CITATION.cff"), "u", "r", file.path(d, "DESCRIPTION")),
               "no preferred-citation block")
})

test_that("xct_bib_from_cff writes one TechReport per repository, keyed by name", {
  local_cff_fetch(list(rep_a = cff_report_lines("Report A", 2025), rep_b = cff_report_lines("Report B", 2026)))
  p <- file.path(withr::local_tempdir(), "reports.bib")
  expect_message(out <- xct_bib_from_cff(c("rep_a", "rep_b"), p), "2 report\\(s\\)")
  expect_identical(out, p)
  b <- readLines(p)
  expect_equal(grep("^@", b, value = TRUE), c("@TechReport{rep_a,", "@TechReport{rep_b,"))
  expect_true(any(grepl("title = \\{Report B\\}", b)))
  expect_true(any(grepl("institution = \\{New Graph Environment Ltd.\\}", b)))
})

test_that("no repositories writes an empty file", {
  local_cff_fetch()
  p <- file.path(withr::local_tempdir(), "reports.bib")
  suppressMessages(xct_bib_from_cff(character(), p))
  expect_identical(readLines(p), character())
})

test_that("an unreadable record stops the call and writes nothing", {
  local_cff_fetch(list(rep_a = cff_report_lines()))
  p <- file.path(withr::local_tempdir(), "reports.bib")
  expect_error(xct_bib_from_cff(c("rep_a", "rep_missing"), p), "rep_missing: network called")
  expect_false(file.exists(p))
})

test_that("a record with no report entry stops the call", {
  sw <- cff_report_lines()
  local_cff_fetch(list(sw = sw[seq_len(which(sw == "preferred-citation:") - 1)], junk = "a: [b"))
  p <- file.path(withr::local_tempdir(), "reports.bib")
  expect_error(xct_bib_from_cff("sw", p), "sw: CITATION.cff gave no report entry")
  expect_error(xct_bib_from_cff("junk", p), "junk: CITATION.cff is not a valid citation record")
  expect_false(file.exists(p))
})

test_that("xct_bib_from_cff refuses bad repository names and duplicates", {
  local_cff_fetch()
  p <- file.path(withr::local_tempdir(), "reports.bib")
  expect_error(xct_bib_from_cff("a/b", p), "not a repository name: a/b")
  expect_error(xct_bib_from_cff(NA_character_, p), "not a repository name")
  expect_error(xct_bib_from_cff(c("a", "a"), p), "names a repository twice")
  expect_error(xct_bib_from_cff("a", ""), "`path` must be one non-empty string")
})
