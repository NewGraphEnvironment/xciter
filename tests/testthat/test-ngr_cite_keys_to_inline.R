
path_bib <- system.file("extdata", "references.bib", package = "ngr")
# bib_obj <- RefManageR::ReadBib(path_bib, check = "warn")

# First test: Function runs properly formated keys when default csl used
testthat::test_that("ngr_cite_keys_to_inline runs and returns character", {
  result <- ngr_cite_keys_to_inline(
    "test this [@busch_etal2011LandscapeLevelModela] and that @woll_etal2017SalmonEcological",
    path_bib
    )
  testthat::expect_equal(result, "test this (Busch et al. 2011) and that Woll, Albert, and Whited (2017)")  # Checks if result is a tibble
})




