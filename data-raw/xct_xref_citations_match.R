# from https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/blob/main/scripts/bib_repair.R


keys_missing <- c(
  "officeofthewetsuweten2013Wetsuweta",
  "flnrord2017NaturalResourcea",
  "gottesfeldSkeenaFishPopulations2007",
  "eccc2016Climatedataa",
  "ilmb2007MoriceLanda",
  "wilsonFishPassageAssessment2007",
  "flnroBulkleyRiverAngling2013",
  "flnroOverviewAnglingManagement2013",
  "flnrordFreshwaterFishingRegulations2019",
  "dysonBulkleyFallsInvestigation1949",
  "stokesUpperBulkleyRiver1956",
  "bustardConservingMoriceWatershed2002",
  "gottesfeldConservingSkeenaFish2002",
  "schellBriefOverviewFish2003",
  "oliverAnalysisWaterQuality2018",
  "beechieProcessbasedPrinciplesRestoring2010",
  "ciottiDesignCriteriaProcessBased2021a"
)
path_bib <- system.file("extdata", "NewGraphEnvironment.bib", package = "xciter")

keys_matched <- xciter::xct_keys_guess_match(
  keys_missing,
  keys_bib = xciter::xct_bib_keys_extract(path_bib),
  stringdist_threshold = 25,
  no_match_rows_include = TRUE
) |>
  dplyr::arrange(key_missing)

# we have mismatches that we need to custom!!!!!!!!!!!! We see the by very CARFEFUL comparison between
# what is proposed and what they are meant to be. We use the old .bib file and zotero (or the NewGraphEnvironment.bib file in xciter)
# lets make a xref for these pesky ones that are going to rear their heads over and over again

# here are their indexes
keys_fix_idx <- c(3, 6, 10, 11, 17)
xref_citations_match <- keys_matched |>
  dplyr::filter(dplyr::row_number() %in% keys_fix_idx) |>
  dplyr::mutate(
    key_match = dplyr::case_when(
      key_missing == "ciottiDesignCriteriaProcessBased2021a" ~ "ciotti_etal2021DesignCriteria",
      key_missing == "flnroBulkleyRiverAngling2013" ~ "flnro2013BulkleyRiver",
      key_missing == "gottesfeldConservingSkeenaFish2002" ~ "gottesfeld_etal2002ConservingSkeena",
      key_missing == "gottesfeldSkeenaFishPopulations2007" ~ "gottesfeld_rabnett2007SkeenaFish",
      key_missing == "wilsonFishPassageAssessment2007" ~ "wilson_rabnett2007FishPassage")
  )

# save
xref_citations_match  |>
  readr::write_csv("inst/extdata/xct_xref_citations_match.csv")

