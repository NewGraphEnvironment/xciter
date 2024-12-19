
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xciter

![Haywire](https://img.shields.io/badge/status-haywire-red)
![MaybeNotHelpful](https://img.shields.io/badge/NeverMind-MaybeNotHelpful-green)

This package focuses solely on “extra” functions related to citeing
bibliography items such as processing .bib files to get citation keys,
processing BiBtex keys to get inline citations, etc. We are calling it
“extra” because we rely heavily on
[`rbbt`](https://github.com/paleolimbot/rbbt) and standard
`rmarkdown::render` magic to almost everything we need to do. Some
functions for rendering citation keys as inline references wrap calls to
`pandoc` so that needs to be installed. If you have Rstudion you likely
have it already.

This package deals with a few problems as follows:

- Identify all citation keys in documents and confirm their presence in
  a specified .bib file.
- Highlight citation keys that do not match and suggest the closest
  matching keys from the .bib file.
- Provide workarounds for citation handling in interactive tables
  [(DT)](https://github.com/rstudio/DT) and other HTML outputs where
  standard citation rendering in R Markdown and Quarto may fail.

## Installation

You can install the development version of xciter from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
pak::pkg_install("NewGraphEnvironment/xciter")
```

## Example

This is a basic example of subbing citation keys for inline references
within a table so that it can be rendered as is after the changes are
made:

``` r
library(xciter)
## basic example code

path_bib <- system.file("extdata", "NewGraphEnvironment.bib", package = "xciter")
dat <- data.frame(
  id = 1:3,
  bib_keys = c(
    "Outside block quotes @busch_etal2011LandscapeLevelModela and in [@woll_etal2017SalmonEcological]",
    "This is many [@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventorya]",
    "this is a failed key @key3"
  )
)
result <- xct_keys_to_inline_table_col(dat, col_format = "bib_keys", path_bib = path_bib)
print(result)
#>   id
#> 1  1
#> 2  2
#> 3  3
#>                                                                                             bib_keys
#> 1                    Outside block quotes Busch et al. (2011) and in (Woll, Albert, and Whited 2017)
#> 2 This is many (Busch et al. 2011; Woll, Albert, and Whited 2017; Kirsch, Buckwalter, and Reed 2014)
#> 3                                                                       this is a failed key (key3?)
```

This is a basic example of checking if the citation keys within a
bookdown document are found within a specified `.bib` file.

``` r
key_missing <- xct_bib_keys_missing(path_bib, "kirsch_etal2014Fishinventory")
#> ! The following citations were not found in the BibTeX file:
#> [1] "kirsch_etal2014Fishinventory"
```

<br>

This is an example of how to search for the closest match for an
unmatched key.

``` r
xct_keys_guess_match(key_missing, keys_bib = xct_bib_keys_extract(path_bib))
#>                    key_missing       key_missing_guess_match
#> 1 kirsch_etal2014Fishinventory kirsch_etal2014Fishinventorya
```
