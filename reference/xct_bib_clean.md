# Check for Missing Citation Keys in a BibTeX File

This function identifies citation keys provided in a list that are
missing from a specified BibTeX file. It ensures the BibTeX file exists
and processes the file to match the citation keys.

This function extracts all citation keys from a given BibTeX file.

This function attempts to find the closest matching citation keys for
keys that are missing from a BibTeX file, based on string distance.
Users can set a threshold for the maximum allowable distance for a
match, optionally exclude rows where no matches are close enough, and
choose the string distance calculation method.

## Usage

``` r
xct_bib_keys_missing(path_bib, citations)

xct_bib_keys_extract(path_bib)

xct_keys_guess_match(
  keys_missing,
  keys_bib,
  stringdist_threshold = 15,
  stringdist_method = "dl",
  no_match_rows_include = FALSE
)
```

## Arguments

- path_bib:

  A file path to the bibliography file (`.bib`) used for citation keys.
  Defaults to `"references.bib"` in the current working directory.

- keys_missing:

  [character](https://rdrr.io/r/base/character.html) A vector of
  citation keys that are missing from the BibTeX file. Typically
  obtained using `xct_bib_keys_missing()`.

- keys_bib:

  [character](https://rdrr.io/r/base/character.html) A vector of
  citation keys extracted from the BibTeX file. Typically obtained using
  `xct_bib_keys_extract()`.

- stringdist_threshold:

  [numeric](https://rdrr.io/r/base/numeric.html) The maximum allowable
  string distance for a match to be considered valid. This value is
  passed to `[stringdist::stringdist()]` for the specified method.
  Distances are non-negative numeric values where smaller values
  indicate greater similarity. For short strings (5-10 characters), use
  `1-3`; for medium strings (10-20 characters), use `3-7`; and for
  longer strings (\>20 characters), use `7-15`. Default is `15`.
  Interestingly, we see some accurate matches at 25 however we also get
  mismatches when we go this high which could result in incorrect
  citations if we find replace those!!

- stringdist_method:

  [character](https://rdrr.io/r/base/character.html) The method used by
  `[stringdist::stringdist()]` to calculate string distances. Options
  include "osa" (Optimal String Alignment, default), "lv" (Levenshtein),
  "dl" (Damerau-Levenshtein), "jw" (Jaro-Winkler), and others. See
  `[stringdist::stringdist()]` documentation for details. Default is
  "dl".

- no_match_rows_include:

  [logical](https://rdrr.io/r/base/logical.html) Whether to include rows
  for keys with no valid matches in the output. Default is `FALSE`,
  which excludes such rows.

- keys:

  [character](https://rdrr.io/r/base/character.html) A vector of
  citation keys to check for in the BibTeX file.

## Value

A vector of citation keys missing from the BibTeX file. Returns an empty
vector if all citation keys are found.

A character vector of citation keys extracted from the BibTeX file.

A data frame with two columns:

- key_missing:

  The missing citation keys.

- key_missing_guess_match:

  The guessed closest matching citation keys (or `NA` if no valid match
  is found).

If `no_match_rows_include = FALSE`, rows with no valid matches are
excluded.

## See also

`xct_bib_keys_missing()`, `xct_bib_keys_extract()`,
[`stringdist::stringdist()`](https://rdrr.io/pkg/stringdist/man/stringdist.html)

Other cite:
[`xct_keys_extract()`](https://newgraphenvironment.github.io/xciter/reference/xct_keys_extract.md),
[`xct_keys_to_inline()`](https://newgraphenvironment.github.io/xciter/reference/xct_keys_to_inline.md)

## Examples

``` r
if (FALSE) { # \dontrun{
path_bib <- system.file("extdata", "references.bib", package = "xciter")
citations <- c("Smith2020", "Jones2019")
xct_bib_keys_missing(path_bib, citations)
} # }
# Path to the example BibTeX file
path_bib <- system.file("extdata", "references.bib", package = "xciter")

# Define the citation keys to check
keys <- c("busch_etal2011LandscapeLevelModel",
          "kirsch_etal2014Fishinventoryb",
          "test2001")

# Extract keys from the BibTeX file
keys_bib <- xct_bib_keys_extract(path_bib)

# Identify missing keys
keys_missing <- xct_bib_keys_missing(path_bib, keys)
#> ! The following citations were not found in the BibTeX file:
#> [1] "busch_etal2011LandscapeLevelModel" "kirsch_etal2014Fishinventoryb"    
#> [3] "test2001"                         

# Guess matches for missing keys with a string distance threshold and method
xct_keys_guess_match(keys_missing, keys_bib)
#>                         key_missing            key_missing_guess_match
#> 1 busch_etal2011LandscapeLevelModel busch_etal2011LandscapeLevelModela
#> 2     kirsch_etal2014Fishinventoryb       kirsch_etal2014Fishinventory
#> 3                          test2001                      data_fish_obs
```
