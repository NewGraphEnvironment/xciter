
keys <- c(
  "@busch_etal2011LandscapeLevelModel",
  "@busch_etal2011LandscapeLevelModela",
  "@woll_etal2017SalmonEcological",
  "@kirsch_etal2014Fishinventoryb",
  "@test2001"
)

path_bib <- system.file("extdata", "references.bib", package = "ngr")

result <- excitr_bib_keys_missing(path_bib, keys)



test_that("excitr_bib_keys_missing returns expected result", {

  # Expected output
  expected <- c("busch_etal2011LandscapeLevelModel", "kirsch_etal2014Fishinventoryb", "test2001")

  # Assertion
  expect_equal(result, expected)
})

excitr_keys_guess_match(result,
                          keys_bib = excitr_bib_keys_extract(path_bib)
)





