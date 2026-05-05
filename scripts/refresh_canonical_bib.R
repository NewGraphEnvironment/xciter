# Refresh xciter's canonical NewGraphEnvironment.bib from the live Zotero
# library via Better BibTeX's JSON-RPC bulk-export endpoint.
#
# Pre-condition: Zotero is running locally with the Better BibTeX add-on
# active (default JSON-RPC endpoint at http://localhost:23119/better-bibtex/json-rpc).
#
# Usage (from xciter repo root):
#   Rscript scripts/refresh_canonical_bib.R
#
# Pass an integer library_id as the first arg to override the default
# (`getOption("rbbt.default.library_id")` if set, else 1).
#
# After running, commit + push xciter, then `pak::pak("NewGraphEnvironment/xciter")`
# in consumer repos.

args <- commandArgs(trailingOnly = TRUE)
library_id <- suppressWarnings(as.integer(args[1]))
if (is.na(library_id)) {
  library_id <- getOption("rbbt.default.library_id", 1L)
}

out_path <- "inst/extdata/NewGraphEnvironment.bib"
if (!file.exists("DESCRIPTION") || !grepl("Package: xciter", readLines("DESCRIPTION", n = 1))) {
  stop("Run from xciter repo root — DESCRIPTION not found or wrong package")
}

# Pre-state for sanity-check
prev_lines   <- if (file.exists(out_path)) length(readLines(out_path)) else 0
prev_entries <- if (file.exists(out_path)) length(grep("^@", readLines(out_path))) else 0

cat(sprintf("Refreshing %s from Zotero library_id=%d\n", out_path, library_id))
cat(sprintf("Before: %d entries, %d lines\n", prev_entries, prev_lines))

# Verify Zotero+BBT reachable before bulk export
ok <- tryCatch(rbbt::has_bbt(), error = function(e) FALSE)
if (!isTRUE(ok)) {
  stop("Zotero+BBT not reachable. Make sure Zotero is running with Better BibTeX active.")
}

# Resolve library name from id (for filtering search results, since
# item.search returns items from all libraries with a `library` name field).
libs <- rbbt::bbt_libraries()
lib_row <- libs[libs$id == library_id, , drop = FALSE]
if (nrow(lib_row) == 0) {
  stop(sprintf("library_id %d not found in bbt_libraries(). Available: %s",
               library_id, paste(libs$id, libs$name, sep = "=", collapse = ", ")))
}
library_name <- lib_row$name[1]
cat(sprintf("Library name: %s\n", library_name))

# Step 1: enumerate all citekeys in the target library.
# BBT doesn't expose a `library.export` bulk endpoint in this version,
# but `item.search(" ")` returns every item across all libraries with
# `citekey` and `library` fields. Filter to the target library.
cat("Enumerating items via item.search ...\n")
search_resp <- rbbt::bbt_call_json_rpc("item.search", " ")
if (!is.null(search_resp$error)) {
  stop("item.search error: ", search_resp$error$message)
}
all_items <- search_resp$result
cat(sprintf("Total items across all libraries: %d\n", length(all_items)))

in_target <- vapply(all_items,
                    function(x) identical(x$library, library_name),
                    logical(1))
target_items <- all_items[in_target]
target_keys  <- vapply(target_items, function(x) x$citekey, character(1))
cat(sprintf("Items in '%s': %d\n", library_name, length(target_keys)))

# BBT's item.export lookup chokes on citekeys containing `@` (typically
# auto-generated from email-based author names like dfg_webmaster@alaska.gov).
# Filter them out — they're unlikely to be cited in Rmd prose anyway.
bad_keys <- target_keys[grepl("@", target_keys, fixed = TRUE)]
if (length(bad_keys) > 0) {
  cat(sprintf("Skipping %d keys containing '@' (BBT export lookup limitation):\n",
              length(bad_keys)))
  for (k in bad_keys) cat(sprintf("  - %s\n", k))
  target_keys <- target_keys[!grepl("@", target_keys, fixed = TRUE)]
}

# Step 2: bulk-export in batches so a single bad key doesn't kill the whole
# export. Batch size 200 is conservative.
batch_size <- 200
batches <- split(target_keys, ceiling(seq_along(target_keys) / batch_size))
cat(sprintf("Exporting %d keys via item.export in %d batches of <=%d ...\n",
            length(target_keys), length(batches), batch_size))

bib_chunks  <- character(0)
failed_keys <- character(0)
for (i in seq_along(batches)) {
  batch <- batches[[i]]
  resp <- rbbt::bbt_call_json_rpc(
    "item.export",
    as.list(batch),
    "biblatex",
    library_id
  )
  if (!is.null(resp$error)) {
    cat(sprintf("  batch %d (%d keys): error '%s' — falling back to one-by-one\n",
                i, length(batch), resp$error$message))
    for (k in batch) {
      r <- rbbt::bbt_call_json_rpc(
        "item.export", as.list(k), "biblatex", library_id
      )
      if (!is.null(r$error)) {
        failed_keys <- c(failed_keys, k)
      } else {
        bib_chunks <- c(bib_chunks, r$result)
      }
    }
  } else {
    bib_chunks <- c(bib_chunks, resp$result)
  }
}

if (length(failed_keys) > 0) {
  cat(sprintf("Skipped %d keys that failed individual export:\n", length(failed_keys)))
  for (k in failed_keys) cat(sprintf("  - %s\n", k))
}

bib_text <- paste(bib_chunks, collapse = "\n")
if (!nzchar(bib_text)) stop("Empty bib text after batched export")

# Write to file
writeLines(bib_text, out_path)

# Post-state
new_lines   <- length(readLines(out_path))
new_entries <- length(grep("^@", readLines(out_path)))
cat(sprintf("After:  %d entries, %d lines\n", new_entries, new_lines))
cat(sprintf("Delta:  %+d entries, %+d lines\n",
            new_entries - prev_entries, new_lines - prev_lines))

cat("\nNext steps:\n")
cat("  cd ~/Projects/repo/xciter\n")
cat("  git add inst/extdata/NewGraphEnvironment.bib\n")
cat("  git commit -m 'Refresh canonical bib from Zotero (' $(date +%Y-%m-%d) ')'\n")
cat("  git push\n")
cat("  # then in consumer repos:\n")
cat("  pak::pak('NewGraphEnvironment/xciter')\n")
