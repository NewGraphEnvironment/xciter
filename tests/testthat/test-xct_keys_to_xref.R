# Shared setup for tests
citation_keys <- c(
  "@busch_etal2011LandscapeLevelModela",
  "[@woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
  "[@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
  "[@test2001]"
)
path_bib <- system.file("extdata", "references.bib", package = "ngr")
bib_obj <- RefManageR::ReadBib(path_bib, check = "warn")


# First test: Function runs and returns a data.frame
testthat::test_that("xct_keys_to_xref runs and returns data.frame", {
  skip_if_not_installed("RefManageR")
  result <- suppressWarnings(
    xct_keys_to_xref(citation_keys, path_bib, key_abort_on_missing = FALSE, key_check_response = FALSE)
  )
  expect_s3_class(result, "data.frame")  # Checks if result is a tibble
})

# Second test: Function aborts with an error on missing keys
testthat::test_that("xct_keys_to_xref aborts with missing keys", {
  skip_if_not_installed("RefManageR")
  expect_error(
    suppressWarnings(
      xct_keys_to_xref(citation_keys, path_bib, key_abort_on_missing = TRUE, key_check_response = FALSE)
      ),
    "Citation key not found in bibliography: test2001"
  )
})

# Test xct_format_single function with different citation formats
testthat::test_that("xct_format_single works with bare key", {
  skip_if_not_installed("RefManageR")
  result <- suppressWarnings(
    xct_format_single("busch_etal2011LandscapeLevelModela", bib = bib_obj)
  )
  expect_true(!is.null(result))
})

testthat::test_that("xct_format_single works with '@' prefix", {
  skip_if_not_installed("RefManageR")
  result <- suppressWarnings(
    xct_format_single("@busch_etal2011LandscapeLevelModela", bib = bib_obj)
  )
  expect_true(!is.null(result))
})

# Test that a warning is thrown when key_abort_on_missing is FALSE
testthat::test_that("xct_keys_to_xref throws a warning when key_abort_on_missing is FALSE", {
  skip_if_not_installed("RefManageR")
  options(warn = -1)  # Suppresses all warnings
  expect_warning(
      xct_keys_to_xref(citation_keys, path_bib, key_abort_on_missing = FALSE)
  )
  # Reset warning option to default
  options(warn = 0)
})

# Expect warning when citation keys are missing an entry
testthat::test_that("xct_keys_to_xref does not throw warning when key_check_response is FALSE", {
  skip_if_not_installed("RefManageR")
  expect_warning(
    xct_keys_to_xref(citation_keys, path_bib, key_abort_on_missing = FALSE, key_check_response = FALSE),
    "Citation key not found in bibliography: test2001"
  )
})

# Test that no warning is thrown when key_check_response is FALSE
testthat::test_that("xct_keys_to_xref does not throw warning when key_check_response is FALSE", {
  skip_if_not_installed("RefManageR")
  citation_keys <- c(
    "@busch_etal2011LandscapeLevelModela",
    "[@woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
    "[@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]"
    )
  expect_no_warning(
    xct_keys_to_xref(citation_keys, path_bib, key_abort_on_missing = FALSE, key_check_response = FALSE)
  )
})



