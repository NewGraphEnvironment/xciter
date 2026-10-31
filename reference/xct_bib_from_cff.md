# Write a bibliography of reports from their own CITATION.cff records

A report that cites another report can cite it by that report's own
`CITATION.cff`, the one record its citations come from, rather than by a
reference-manager entry typed from it. Each repository's record is read
from its default branch on GitHub, converted with
[`cffr::as_bibentry()`](https://docs.ropensci.org/cffr/reference/as_bibentry.html)
using `what = "preferred"` (a `@TechReport` naming the publisher as
institution), and keyed by the repository name, so a report is cited as
`[@<repo>]`.

## Usage

``` r
xct_bib_from_cff(repos, path, owner = "NewGraphEnvironment")
```

## Arguments

- repos:

  [character](https://rdrr.io/r/base/character.html) Repository names to
  cite. An empty vector writes an empty file.

- path:

  [character](https://rdrr.io/r/base/character.html) Path of the `.bib`
  file to write.

- owner:

  [character](https://rdrr.io/r/base/character.html) The GitHub owner of
  the repositories.

## Value

`path`, invisibly.

## Details

Any record that cannot be read, does not validate, or gives no report
entry with a title and authors stops the call: a bibliography that
silently drops an entry would render that citation unresolved with
nothing to say why. The file is written atomically.

The repositories must be public: no token is sent.

## See also

Other cff:
[`xct_cff_refresh()`](https://newgraphenvironment.github.io/xciter/reference/xct_cff_refresh.md)

## Examples

``` r
if (FALSE) { # \dontrun{
xct_bib_from_cff(
  c("fish_passage_peace_2024_reporting", "fish_passage_skeena_2024_reporting"),
  path = file.path(tempdir(), "references-reports.bib")
)
} # }
```
