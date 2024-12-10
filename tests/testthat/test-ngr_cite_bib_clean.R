
keys <- c(
  "@busch_etal2011LandscapeLevelModel",
  "@busch_etal2011LandscapeLevelModela",
  "@woll_etal2017SalmonEcological",
  "@kirsch_etal2014Fishinventoryb",
  "@test2001"
)

path_bib <- system.file("extdata", "references.bib", package = "ngr")

result <- ngr_cite_bib_keys_missing(path_bib, keys)



test_that("ngr_cite_bib_keys_missing returns expected result", {

  # Expected output
  expected <- c("busch_etal2011LandscapeLevelModel", "kirsch_etal2014Fishinventoryb", "test2001")

  # Assertion
  expect_equal(result, expected)
})

ngr_cite_keys_guess_match(result,
                          keys_bib = ngr_cite_bib_keys_extract(path_bib)
)





