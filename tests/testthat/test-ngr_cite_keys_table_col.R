
bib_file <- system.file("extdata", "references.bib", package = "ngr")
# bib_obj <- RefManageR::ReadBib(bib_file, check = "warn")

# Example data frame
df <- data.frame(
  id = 1:3,
  bib_keys = c(
    "Outside block quotes @busch_etal2011LandscapeLevelModela and in [@woll_etal2017SalmonEcological]",
    "This is many [@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
    "this is a failed key @key3")
)

result <- ngr_cite_keys_table_col(df, col_format = "bib_keys", bib_file = bib_file)

# Function runs and returns a data.frame
testthat::test_that("ngr_cite_keys_table_col runs and returns data.frame", {
  expect_s3_class(result, "data.frame")  # Checks if result is a tibble
})

# Function returns a data.frame different from the one input
testthat::test_that("ngr_cite_keys_table_col returns new data.frame", {
  testthat::expect_false(identical(df, result))
})

