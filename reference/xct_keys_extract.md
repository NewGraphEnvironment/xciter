# Extract Citations from Text

This function extracts citations in the form of `@citation` or
`[e.g., @citation1; @citation2]` from a given text. Additional citations
can also be included via a parameter.

This function extracts citation keys from a specified column in a data
frame and optinally formats them as a character vector or prints them
row-wise for easy copy-pasting into the `nocite` line of YAML in an R
Markdown document. This can be handy when we are using
`xct_keys_extract()` to format a table column for reporting but we
require the citation keys so that they show up in the references section
of the overall report.

## Usage

``` r
xct_keys_extract(text, keys_additional = NULL)

xct_keys_extract_table(dat, col_format, print_rowwise = TRUE, ...)
```

## Arguments

- text:

  A character string containing the text to process. Passing `NA` will
  issue a warning.

- keys_additional:

  A character vector of additional citation keys to include. Default is
  `NULL`.

- dat:

  A data frame containing the column to transform.

- col_format:

  A string specifying the name of the column to transform.

- print_rowwise:

  Logical. If `TRUE`, formats and prints keys row-wise with a trailing
  comma for easy YAML compatibility. Defaults to `TRUE`.

- ...:

  Can be used to pass additional citation keys to `xct_keys_extract()`
  in case there are citation keys additional to the ones in the table
  that you want in the output.

## Value

A character vector of unique citation keys.

A character vector of citation keys extracted from a data frame column.

## Details

This function builds on `xct_keys_extract()`, and integrates its
functionality for working with citation keys extracted from a data
frame.

## See also

`xct_keys_extract()`

Other cite:
[`xct_bib_keys_missing()`](https://newgraphenvironment.github.io/xciter/reference/xct_bib_clean.md),
[`xct_keys_to_inline()`](https://newgraphenvironment.github.io/xciter/reference/xct_keys_to_inline.md)
