
path_bib <- system.file("extdata", "references.bib", package = "ngr")

# Example data frame
dat <- data.frame(
  id = 1:4,
  bib_keys = c(
    "Outside block quotes @busch_etal2011LandscapeLevelModela and in [@woll_etal2017SalmonEcological]",
    "This is many [@busch_etal2011LandscapeLevelModela; @woll_etal2017SalmonEcological; @kirsch_etal2014Fishinventory]",
    "this is a failed key @key3 with a newline symbol /n  ",
    "Design long-term water monitoring program to leverage past work and attempt to quantify upstream water quality impacts via tools such as [CABIN](https://www.canada.ca/en/environment-climate-change/services/canadian-aquatic-biomonitoring-network/resources.html) sampling program [@busch_etal2011LandscapeLevelModela], 5 sample in 30 day water quality sampling during both high and low flow periods [@busch_etal2011LandscapeLevelModela; @busch_etal2011LandscapeLevelModela], continuation/expansion of [temperature monitoring](https://public.tableau.com/app/profile/skeena.knowledge.trust/viz/UBRWaterTemperatureMonitoringDashboardDraft/UBRWaterTemp_Dashboard) [@skeenaknowledgetrustUBRWater, @westcott2022UpperBulkleya], quantify amounts of water withdrawn by licensees in the upper Bulkley catchment during the April to September low flow period, etc. Importantly, careful consideration of how to implement water quality program recommendations from @price2014UpperBulkleya, @oliver2020Analysis2017 and @westcott2022UpperBulkleya during this process is also recommended.")
)

result <- excitr_keys_to_inline_table_col(dat, col_format = "bib_keys", path_bib = path_bib)

# Function runs and returns a data.frame
testthat::test_that("excitr_keys_to_inline_table_col runs and returns data.frame", {
  expect_s3_class(result, "data.frame")  # Checks if result is a tibble
})

# Function returns a data.frame different from the one input
testthat::test_that("excitr_keys_to_inline_table_col returns new data.frame", {
  testthat::expect_false(identical(dat, result))
})

