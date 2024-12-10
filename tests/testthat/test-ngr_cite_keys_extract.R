# Expected output
expected_output <- c(
  "@canada2008CanadianAquatic",
  "@wlrs2024BritishColumbia",
  "@moe2024BritishColumbia",
  "@skeenaknowledgetrustUBRWater",
  "@westcott2022UpperBulkleya",
  "@price2014UpperBulkleya",
  "@oliver2020Analysis2017",
  "@ministryofforestsRiparianmanagement",
  "@johnston_slaney1996FishHabitat"
  )

# Expected output for row-wise printing
expected_output_rowwise <- c(
  "@canada2008CanadianAquatic,",
  "@wlrs2024BritishColumbia,",
  "@moe2024BritishColumbia,",
  "@skeenaknowledgetrustUBRWater,",
  "@westcott2022UpperBulkleya,",
  "@price2014UpperBulkleya,",
  "@oliver2020Analysis2017,",
  "@ministryofforestsRiparianmanagement,",
  "@johnston_slaney1996FishHabitat"
)


# Test the function
result <- ngr_cite_keys_extract_table(
  dat = table_test,
  col_format = "Details",
  print_rowwise = FALSE)

result_printed <- capture.output(
  ngr_cite_keys_extract_table(table_test, "Details", print_rowwise = TRUE)
)

test_that("ngr_cite_keys_extract_table generates list when print_rowwise = FALSE", {
  expect_equal(result, expected_output)
})

test_that("ngr_cite_keys_extract_table generates collapsed list when print_rowwise = TRUE", {
  expect_equal(result_printed, expected_output_rowwise)
})

test_that("ngr_cite_keys_extract works correctly with additional keys input", {
  # Input text and additional keys
  input_text <- "try @thistest2001"
  keys_additional <- c("@that", "@theother")

  # Expected result
  expected_result <- c("@thistest2001", "@that", "@theother")

  # Run the function
  result <- ngr_cite_keys_extract(input_text, keys_additional)

  # Assert that the result matches the expected output
  expect_equal(result, expected_result)
})
