# Shared setup for tests
citation_keys <- c(
  "@busch_etal2011LandscapeLevelModela",
  "[@woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
  "[@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
  "[@test2001]"
)
bib_file <- system.file("extdata", "references.bib", package = "ngr")
bib_obj <- RefManageR::ReadBib(bib_file, check = "warn")

# First test: Function runs and returns a tibble
test_that("ngr_cite_key_to_inline runs and returns a tibble", {
  result <- ngr_cite_key_to_inline(citation_keys, bib_file, key_abort_on_missing = FALSE)
  expect_true(inherits(result, "tbl_df"))  # Checks if result is a tibble
})

# Second test: Function aborts with an error on missing keys
test_that("ngr_cite_key_to_inline aborts with missing keys", {
  expect_error(
    suppressWarnings(
      ngr_cite_key_to_inline(citation_keys, bib_file, key_abort_on_missing = TRUE)
      ),
    "Citation key not found in bibliography: test2001"
  )
})

# Test ngr_cite_format_single function with different citation formats
test_that("ngr_cite_format_single works with bare key", {
  result <- ngr_cite_format_single("busch_etal2011LandscapeLevelModela", bib = bib_obj)
  expect_true(!is.null(result))
})

test_that("ngr_cite_format_single works with '@' prefix", {
  result <- ngr_cite_format_single("@busch_etal2011LandscapeLevelModela", bib = bib_obj)
  expect_true(!is.null(result))
})
