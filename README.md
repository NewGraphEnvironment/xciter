
<!-- README.md is generated from README.Rmd. Please edit that file -->

# xciter

![Experimental](https://img.shields.io/badge/status-experimental-orange)
![Haywire](https://img.shields.io/badge/status-haywire-red)

This package focuses solely on “extra” functions related to citeing
bibliography items such as processing .bib files to get citation keys,
processing BiBtex keys to get inline citations, etc. This work was
inspired by the need to find a way to process citation keys to inline
citation text in DT tables as rendering in rmarkdown does not produce
the results we desire so we need to do it with manual calls to `pandoc`.

## Installation

You can install the development version of ngr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
pak::pkg_install("NewGraphEnvironment/ngr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(xciter)
## basic example code

path_bib <- system.file("extdata", "references.bib", package = "ngr")
dat <- data.frame(
  id = 1:3,
  bib_keys = c(
    "Outside block quotes @busch_etal2011LandscapeLevelModela and in [@woll_etal2017SalmonEcological]",
    "This is many [@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
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
