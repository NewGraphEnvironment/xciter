# Changelog

## xciter 0.1.0 (2026-10-31)

First release.

- **Citation records for reports.**
  [`xct_cff_refresh()`](https://newgraphenvironment.github.io/xciter/reference/xct_cff_refresh.md)
  refreshes a report’s own `CITATION.cff` for the version being built:
  the build date, the version from `DESCRIPTION`, the report and
  repository URLs, and a Zenodo DOI from `Config/DOI` when there is one.
  Nothing is written unless the result passes
  [`cffr::cff_validate()`](https://docs.ropensci.org/cffr/reference/cff_validate.html).
  [`xct_bib_from_cff()`](https://newgraphenvironment.github.io/xciter/reference/xct_bib_from_cff.md)
  builds a `@TechReport` entry for each cited report from that report’s
  public `CITATION.cff`, keyed by repository name, and stops on a record
  it cannot read or convert.
- **[`xct_keys_guess_match()`](https://newgraphenvironment.github.io/xciter/reference/xct_bib_clean.md)**
  takes a maximum string distance for a match, with new defaults, tests
  and a working example.
- **`inst/extdata/xct_xref_citations_match.csv`**: a curated table of
  hard-to-match citation keys and the keys they resolve to, for reuse
  across repositories
  ([\#2](https://github.com/NewGraphEnvironment/xciter/issues/2)).
- **The bundled bibliography**, `inst/extdata/NewGraphEnvironment.bib`,
  is refreshed by `scripts/bib_refresh_canonical.R`, sorted by key, and
  no longer carries the `file` field (local attachment paths).
- **`xct_keys_to_xref()` is deactivated** (moved to
  `inst/deactivated/`), so nothing exported uses RefManageR
  ([\#3](https://github.com/NewGraphEnvironment/xciter/issues/3)).
- `xct_bib_clean()` sorts the keys it returns.
- The package is cited through `inst/CITATION` and `CITATION.cff`, with
  New Graph Environment Ltd. as copyright holder and publisher.

## xciter 0.0.0.9001 (2024-12-12)

- replace the last of the ngr occurances with
  <https://gist.github.com/NewGraphEnvironment/b8ac283abfb9f3664bb0691f69ecbe84>
