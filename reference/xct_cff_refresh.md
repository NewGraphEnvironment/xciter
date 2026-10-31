# Refresh a report's CITATION.cff for the version being built

A report's `CITATION.cff` is the one record its citations come from. Its
title and authors are written by hand; this function rewrites only what
a build changes, so it can run at the end of every build:

## Usage

``` r
xct_cff_refresh(
  path = "CITATION.cff",
  report_url,
  repo_url,
  desc = "DESCRIPTION",
  today = Sys.Date()
)
```

## Arguments

- path:

  [character](https://rdrr.io/r/base/character.html) Path to the
  `CITATION.cff` to refresh. It must exist and carry a
  `preferred-citation` block.

- report_url:

  [character](https://rdrr.io/r/base/character.html) The URL the report
  is served at.

- repo_url:

  [character](https://rdrr.io/r/base/character.html) The URL of the
  report's source repository.

- desc:

  [character](https://rdrr.io/r/base/character.html) Path to the
  `DESCRIPTION` that holds `Version` and, optionally, `Config/DOI`.

- today:

  [Date](https://rdrr.io/r/base/Dates.html) The date to stamp. Defaults
  to [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

The refreshed record as a list, invisibly.

## Details

- `date-released`, and `date-published` and `year` in
  `preferred-citation`: the build date, because the version on the web
  is the one being dated;

- `version`, at both levels: `Version` in `DESCRIPTION`, so a citation
  names the version it was made from as well as the date;

- `url` and `repository-code`, at both levels;

- `doi`, at both levels: `Config/DOI` in `DESCRIPTION`, when the
  repository is archived (a Zenodo concept DOI, for example).

The refreshed record must pass
[`cffr::cff_validate()`](https://docs.ropensci.org/cffr/reference/cff_validate.html)
before it replaces `path`; otherwise nothing is written.

## See also

Other cff:
[`xct_bib_from_cff()`](https://newgraphenvironment.github.io/xciter/reference/xct_bib_from_cff.md)

## Examples

``` r
d <- tempfile("report_")
dir.create(d)
writeLines(c("Package: report", "Version: 0.2.0"), file.path(d, "DESCRIPTION"))
writeLines(c(
  "cff-version: 1.2.0",
  "message: If you use this report, please cite it as below.",
  "title: A report",
  "authors:",
  "- family-names: Irvine",
  "  given-names: Allan",
  "type: software",
  "preferred-citation:",
  "  type: report",
  "  title: A report",
  "  authors:",
  "  - family-names: Irvine",
  "    given-names: Allan",
  "  institution:",
  "    name: New Graph Environment Ltd.",
  "  year: 2024"
), file.path(d, "CITATION.cff"))
xct_cff_refresh(
  path = file.path(d, "CITATION.cff"),
  report_url = "https://www.example.com/a_report/",
  repo_url = "https://github.com/example/a_report",
  desc = file.path(d, "DESCRIPTION"),
  today = as.Date("2026-10-31")
)
#> /tmp/Rtmpi3O6VM/report_1a3b76b8b9f3/CITATION.cff refreshed: version 0.2.0 dated 2026-10-31 (no DOI)
cat(readLines(file.path(d, "CITATION.cff")), sep = "\n")
#> cff-version: 1.2.0
#> message: If you use this report, please cite it as below.
#> title: A report
#> authors:
#> - family-names: Irvine
#>   given-names: Allan
#> type: software
#> preferred-citation:
#>   type: report
#>   title: A report
#>   authors:
#>   - family-names: Irvine
#>     given-names: Allan
#>   institution:
#>     name: New Graph Environment Ltd.
#>   year: 2026
#>   date-published: '2026-10-31'
#>   url: https://www.example.com/a_report/
#>   repository-code: https://github.com/example/a_report
#>   version: 0.2.0
#> date-released: '2026-10-31'
#> url: https://www.example.com/a_report/
#> repository-code: https://github.com/example/a_report
#> version: 0.2.0
```
