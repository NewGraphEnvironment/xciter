
keys <- c(
  "@busch_etal2011LandscapeLevelModel",
  "@busch_etal2011LandscapeLevelModela",
  "@woll_etal2017SalmonEcological",
  "@kirsch_etal2014Fishinventoryb",
  "@test2001",
  "@robergeLifeHistory"
)

path_bib <- system.file("extdata", "references.bib", package = "xciter")

keys_missing <- xct_bib_keys_missing(path_bib, keys)



test_that("xct_bib_keys_missing returns expected result", {

  # Expected output
  expected <- c("busch_etal2011LandscapeLevelModel", "kirsch_etal2014Fishinventoryb", "test2001", "robergeLifeHistory")

  # Assertion
  expect_equal(keys_missing, expected)
})

test_that("xct_keys_guess_match emits correct message for stringdist_threshold = 5", {
  expect_message(
    {
      result_match <- xct_keys_guess_match(
        keys_missing, keys_bib,
        stringdist_threshold = 5,
        no_match_rows_include = FALSE
      )
    },
    regexp = "No valid match found for the following keys \\(closest distance exceeds 5 \\): test2001, robergeLifeHistory"
  )
})

test_that("xct_keys_guess_match emits correct message for stringdist_threshold = 10", {
  expect_message(
    {
      result_match <- xct_keys_guess_match(
        keys_missing, keys_bib,
        stringdist_threshold = 10,
        no_match_rows_include = FALSE
      )
    },
    regexp = "No valid match found for the following keys \\(closest distance exceeds 10 \\): test2001"
  )
})

test_that("xct_keys_guess_match returns expected result for stringdist_threshold = 10", {
  result_match <- xct_keys_guess_match(
    keys_missing, keys_bib,
    stringdist_threshold = 10,
    no_match_rows_include = FALSE
  )

  # Reset row names for comparison
  rownames(result_match) <- NULL

  expected_match <- data.frame(
    key_missing = c(
      "busch_etal2011LandscapeLevelModel",
      "kirsch_etal2014Fishinventoryb",
      "robergeLifeHistory"
    ),
    key_missing_guess_match = c(
      "busch_etal2011LandscapeLevelModela",
      "kirsch_etal2014Fishinventory",
      "roberge_etal2002LifeHistory"
    ),
    stringsAsFactors = FALSE
  )

  expect_equal(result_match, expected_match)
})





