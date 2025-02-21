usethis::create_package(".")
usethis::use_testthat(edition = 3)
usethis::use_pkgdown()
usethis::use_github_action("pkgdown")
usethis::use_pkgdown_github_pages()
usethis::use_mit_license()

usethis::use_readme_rmd()
devtools::build_readme()
usethis::use_data_raw("extdata")

usethis::use_test("xct_key_to_inline")

devtools::document()
devtools::test()


# packages
usethis::use_package("RefManageR", type = "Suggests")
usethis::use_package("stringr")

# for testing
devtools::load_all()


devtools::install()
